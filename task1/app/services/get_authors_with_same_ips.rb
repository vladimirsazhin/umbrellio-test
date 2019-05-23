class GetAuthorsWithSameIps
  def call
    tmp = DB[:posts].select do
      [author_ip.as(:ip), author_id, count.function.*.over(partition: :author_ip).as(:ips_count)]
    end

    DB[tmp]
      .select { [ip, array_agg.function(login).distinct.as(:logins)] }
      .where { ips_count > 1 }
      .join(:users, id: :author_id)
      .group(:ip)
  end
end
