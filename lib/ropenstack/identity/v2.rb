module Ropenstack
  ##
  # * Name: IdentityVersion2
  # * Description: An implementation of the V2.0 Identity API Client in Ruby
  # * Author: Sam 'Tehsmash' Betts, John Davidge
  # * Date: 30/06/2014
  ##
  module Identity::Version2
          ##
          # Authenticate via keystone, unless a token and tenant are defined then a unscoped 
          # token is returned with all associated data and stored in the @data variable. 
          # Does not return anything, but all data is accessible through accessor methods.
          ## 	
          def authenticate(username, password, tenant = nil)
                  data = {
                          "auth" => { 
                                  "passwordCredentials" => { 
                                          "username" => username, 
                                          "password" => password 
                                  } 
                          } 
                  }
                  unless tenant.nil?
                          data["auth"]["tenantName"] = tenant
                  end
                  @data = post_request(address("/tokens"), data, @token)
          end

          ##
          # Scope token provides two ways to call it:
          # 	scope_token(tenantName) => Just using the current token and a tenantName it
          # 				   scopes in the token. Token stays the same.
          #	scope_token(username, password, tenantName) => This uses the username and 
          #				   password to reauthenticate with a tenant. The 
          #				   token changes.
          ##
          def scope_token(para1, para2 = nil, para3 = nil)
                  if ( para2.nil? )
                          data = { "auth" => { "tenantName" => para1, "token" => { "id" => token() } } }
                          @data = post_request(address("/tokens"), data, token())
                  else 
                          authenticate(para1, para2, token(), para3)			
                  end
          end

          ##
          # Return the raw @data hash with all the data from authentication.
          ##
          def raw()
                  return @data		
          end

          ##
          # Gets the authentication token from the hash and returns it as a string.
          ##
          def token(token = nil)
                  if token.nil?
                          return @data["access"]["token"]["id"] 
                  else
                          get_request(address("/tokens/#{token}"), token())
                  end
          end

          ##
          # TODO Add head version of tokens call
          ##
          def token?(token)
                  return false
          end

          ##
          # This returns the token and all metadata associated with the token, 
          # including the tenant information.
          ##
          def token_metadata()
                  return @data["access"]["token"]
          end

          ##
          # Return the user hash from the authentication data 
          ##
          def user()
                  return @data["access"]["user"]
          end

          ##
          # Returns true if a user is admin.
          ##
          def admin()
                  @data["access"]["user"]["roles"].each do |role|
                          if role["name"].eql?("admin")
                                  return true
                          end
                  end
                  return false
          end

          ##
          # Get the service catalog returned by Identity on authentication.
          ##
          def services()
                  return @data["access"]["serviceCatalog"]
          end 

          ##
          # Get the tenant id from the @data 
          ##
          def tenant_id()
                  return @data["access"]["token"]["tenant"]["id"]
          end

          def tenant_name()
                  return @data["access"]["token"]["tenant"]["name"] 
          end

          # Separate Identity Calls 

          def tenant_list()
                  return get_request(address('/tenants'), token()) 
          end
          
          ##
          # Add a service to the keystone services directory
          ##
          def add_to_services(name, type, description)
                  data = {
                          'OS-KSADM:service' => {
                                   'name' => name,
                                   'type' => type,
                                   'description' => description
                          }
                  }
                  return post_request(address("/OS-KSADM/services"), data, token())
          end
          
          ##
          # Get list of services
          ##
          def get_services()
                  return get_request(address("/OS-KSADM/services"), token())
          end

          ##
          # Add an endpoint list
          ##
          def add_endpoint(region, service_id, publicurl, adminurl, internalurl)
                  data = {
                          'endpoint' => {
                                  'region' => region,
                                  'service_id' => service_id,
                                  'publicurl' => publicurl,
                                  'adminurl' => adminurl,
                                  'internalurl' => internalurl
                          }
                  }
                  return post_request(address("/endpoints"), data, token())
          end

          ##
          # Get the endpoint list
          ##
          def get_endpoints(token = nil)
                  if token.nil?
                          return get_request(address("/endpoints"), token())
                  else
                          return get_request(address("/tokens/#{token}/endpoints"), token())
                  end
          end

    def address(endpoint)
      super("/v2.0/" + endpoint)
    end

    def version
      "V2"
    end
  end
end
