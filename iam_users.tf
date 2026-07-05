# Create local variables to import users from csv
locals {
    # Import user data from users.csv
    users = csvdecode(file("users.csv"))
}

# Create Users
resource "aws_iam_user" "users" {
    for_each = {
        for user in local.users: lower("${user.lastname}${user.firstname}") => user
    }

    name = each.key
    path = "/teams/${each.value.department}/"
}

# Add Users to User Groups
resource "aws_iam_group_membership" "memberships" {
    for_each = {
        for user in local.users: lower("${user.lastname}${user.firstname}") => user
    }

    name = "${each.key}-${each.value.department}"
    users = [aws_iam_user.users[each.key].name]
    group = aws_iam_group.groups[each.value.department].name
}

# Generate Passwords for Users
resource "aws_iam_user_login_profile" "new_users_login" {
    for_each = {
        for user in local.users: lower("${user.lastname}${user.firstname}") => user
    }

    user = aws_iam_user.users[each.key].name
    password_length = 20
    password_reset_required = true

    # Replace the pgp_key with the user's pgp_key
    # In users.csv, you could include the pgp_key of each user and use it here.connection 
    # For example pgp_key = each.value.pgp_key
    pgp_key = file("my_public_key_base64.txt")

    lifecycle {
      ignore_changes = [ 
        password_length,
        password_reset_required,
        pgp_key
       ]
    }
}