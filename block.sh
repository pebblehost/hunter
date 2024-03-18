# A very very basic script that was thown together in 15 minutes to apply this IP blocklist to the DOCKER-USER chain.
# If you don't run docker, swap out all occurrences of DOCKER-USER for INPUT and this will block the connections on the host machine instead.
# Combine with a cron every few hours, it'll automatically add and remove IPs based on this list.

if [[ `/usr/sbin/ipset list | grep "blacklist"` == "" ]]; then
    /usr/sbin/ipset create blacklist hash:ip
fi
if [[ `/usr/sbin/iptables -w 2 -n -L DOCKER-USER | grep "blacklist"` == "" ]]; then
    /usr/sbin/iptables -I DOCKER-USER -m set --match-set blacklist src -j DROP
fi

blocked_ips=`curl -s "https://raw.githubusercontent.com/pebblehost/hunter/master/ips.txt"`
# Adjust the ipset with the IPs
ipsetrules=`/usr/sbin/ipset list blacklist | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'`
for ip in $blocked_ips; do
    if [[ `echo "$ipsetrules" | grep "$ip"` == "" ]]; then
        echo "Applying block to $ip"
        /usr/sbin/ipset add blacklist $ip/32
    fi
done

for ip in $ipsetrules; do
    if [[ `echo "$blocked_ips" | grep "$ip"` == "" ]]; then
        echo "Removing block from $ip"
        /usr/sbin/ipset del blacklist $ip
    fi
done
unset IFS

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN 
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
