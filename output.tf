output "user_passwords" {
    value = {
        for user in aws_iam_user.users:
            user.name => aws_iam_user_login_profile.new_users_login[user.name].encrypted_password
    }
}