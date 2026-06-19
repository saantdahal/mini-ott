import { getServerAdminName } from "@/lib/auth-server";
import SidebarClient from "@/components/common/SidebarClient";

const Sidebar = async () => {
  const adminName = await getServerAdminName();

  return <SidebarClient initialAdminName={adminName} />;
};

export default Sidebar;
