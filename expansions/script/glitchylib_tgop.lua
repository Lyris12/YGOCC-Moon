--Target/Operation functions and filters
--Simple Target
function Auxiliary.Check(check,info,...)
	local x={...}
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return (not check or check(e,tp,eg,ep,ev,re,r,rp)) end
				if info then
					info(nil,e,tp,eg,ep,ev,re,r,rp)
					if #x>0 then
						for _,extrainfo in ipairs(x) do
							extrainfo(nil,e,tp,eg,ep,ev,re,r,rp)
						end
					end
				end
			end
end
function Auxiliary.CostCheck(check,cost,info,...)
	local x={...}
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					if e:GetLabel()~=1 then return false end
					e:SetLabel(0)
					return not check or check(e,tp,eg,ep,ev,re,r,rp)
				end
				e:SetLabel(0)
				if cost then
					cost(e,tp,eg,ep,ev,re,r,rp)
				end
				if info then
					info(nil,e,tp,eg,ep,ev,re,r,rp)
					if #x>0 then
						for _,extrainfo in ipairs(x) do
							extrainfo(nil,e,tp,eg,ep,ev,re,r,rp)
						end
					end
				end
			end
end
function Auxiliary.LabelCheck(labelcheck,check,info,...)
	local x={...}
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					local l=e:GetLabel()
					local lchk = (l==1) or labelcheck(e,tp,eg,ep,ev,re,r,rp)
					e:SetLabel(0)
					return lchk and (not check or check(e,tp,eg,ep,ev,re,r,rp))
				end
				e:SetLabel(0)
				if info then
					info(nil,e,tp,eg,ep,ev,re,r,rp)
					if #x>0 then
						for _,extrainfo in ipairs(x) do
							extrainfo(nil,e,tp,eg,ep,ev,re,r,rp)
						end
					end
				end
			end
end
function Auxiliary.Target(f,loc1,loc2,min,max,exc,check,info,...)
	local x={...}
	if not min then min=1 end
	if not max then max=min end
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=loc1 end
	return	function (e,tp,eg,ep,ev,re,r,rp,chk,chkc)
				local exc=(not exc) and nil or e:GetHandler()
				if chkc then
					local plchk=(loc1~=0 and chkc:IsControler(tp) and chkc:IsLocation(loc1) or loc2~=0 and chkc:IsControler(1-tp) and chkc:IsLocation(loc2))
					return plchk and (not f or f(chkc,e,tp))
				end
				if chk==0 then return (not check or check(e,tp,eg,ep,ev,re,r,rp)) and Duel.IsExistingTarget(f,tp,loc1,loc2,min,exc,e,tp) end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local g=Duel.SelectTarget(tp,f,tp,loc1,loc2,min,max,exc,e,tp)
				if info then
					info(g,e,tp,eg,ep,ev,re,r,rp)
					if #x>0 then
						for _,extrainfo in ipairs(x) do
							extrainfo(g,e,tp,eg,ep,ev,re,r,rp)
						end
					end
				end
				return g
			end
end

-----------------------------------------------------------------------
--Infos
function Auxiliary.Info(ctg,ct,p,v)
	return	function(_,e,tp)
				local p=(p==0) and tp or 1-tp
				return Duel.SetOperationInfo(0,ctg,nil,ct,p,v)
			end
end
function Auxiliary.HandlerInfo(ctg,ct,p,v)
	return	function(_,e,tp)
				local p=(p==0) and tp or 1-tp
				return Duel.SetOperationInfo(0,ctg,e:GetHandler(),ct,p,v)
			end
end
function Auxiliary.GroupInfo(ctg)
	return	function(g)
				return Duel.SetOperationInfo(0,ctg,g,#g,0,0)
			end
end
function Auxiliary.SelfInfo(ctg)
	return	function(_,e)
				return Duel.SetOperationInfo(0,ctg,e:GetHandler(),1,0,0)
			end
end

-----------------------------------------------------------------------
--Activate
function Auxiliary.ActivateFilter(f)
	return	function(c,e,tp)
				return (not f or f(c,e,tp)) and c:GetActivateEffect():IsActivatable(tp,true,true)
			end
end
function Auxiliary.ActivateFilterIgnoringPlayer(f)
	return	function(c,e,tp)
				local act=c:GetActivateEffect()
				if not act then return false end
				local save_prop=act:GetProperty()
				if not act:IsHasProperty(EFFECT_FLAG_BOTH_SIDE) then
					act:SetProperty(save_prop+EFFECT_FLAG_BOTH_SIDE)
				end
				local check=act:IsActivatable(tp,true,true)
				act:SetProperty(save_prop)
				return (not f or f(c,e,tp)) and check
			end
end
function Auxiliary.ActivateFieldSpellTarget(f,loc1,loc2,exc)
	if not loc1 then loc1=LOCATION_DECK end
	if not loc2 then loc2=0 end
	if loc2>0 then f=aux.ActivateFilterIgnoringPlayer(f) else f=aux.ActivateFilter(f) end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if exc then exc=e:GetHandler() end
				if chk==0 then return Duel.IsExistingMatchingCard(f,tp,loc1,loc2,1,exc,e,tp) end
				if not Duel.CheckPhaseActivity() then Duel.RegisterFlagEffect(tp,CARD_MAGICAL_MIDBREAKER,RESET_CHAIN,0,1) end
				if loc1>0 and loc2>0 then
					Duel.SetCustomOperationInfo(0,CATEGORY_ACTIVATE,nil,1,PLAYER_ALL,loc1|(loc2&(~loc1)))
				elseif loc1>0 then
					Duel.SetCustomOperationInfo(0,CATEGORY_ACTIVATE,nil,1,tp,loc1)
				elseif loc2>0 then
					Duel.SetCustomOperationInfo(0,CATEGORY_ACTIVATE,nil,1,1-tp,loc1)
				end
			end
end
function Auxiliary.ActivateFieldSpellOperation(f,loc1,loc2,exc)
	if not loc1 then loc1=LOCATION_DECK end
	if not loc2 then loc2=0 end
	if loc2>0 then f=aux.ActivateFilterIgnoringPlayer(f) else f=aux.ActivateFilter(f) end
	if (loc1|loc2)&LOCATION_GRAVE>0 then f=aux.NecroValleyFilter(f) end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				if exc then exc=e:GetHandler() end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
				local g=Duel.SelectMatchingCard(tp,f,tp,loc1,loc2,1,1,exc,e,tp)
				if #g>0 then
					local check=aux.PlayFieldSpell(g:GetFirst(),e,tp,eg,ep,ev,re,r,rp)
					return g,check
				end
				return g,false
			end
end

-----------------------------------------------------------------------
--Destroy
function Auxiliary.DestroyFilter(f)
	return	function(c,e,...)
				return (not f or f(c,e,...)) and c:IsDestructable(e)
			end
end
function Auxiliary.DestroyTarget(f,loc1,loc2,min,exc)
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=LOCATION_ONFIELD end
	if (loc1|loc2)&(LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)>0 then f=aux.DestroyFilter(f) end
	if not min then min=1 end
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				if exc then exc=e:GetHandler() end
				if chk==0 then return Duel.IsExistingMatchingCard(f,tp,loc1,loc2,min,exc,e,tp) end
				if loc1>0 and loc2>0 then
					Duel.SetCustomOperationInfo(0,CATEGORY_DESTROY,nil,min,PLAYER_ALL,loc1|(loc2&(~loc1)))
				elseif loc1>0 then
					Duel.SetCustomOperationInfo(0,CATEGORY_DESTROY,nil,min,tp,loc1)
				elseif loc2>0 then
					Duel.SetCustomOperationInfo(0,CATEGORY_DESTROY,nil,min,1-tp,loc1)
				end
			end
end
function Auxiliary.DestroyOperation(f,loc1,loc2,min,max,exc)
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=LOCATION_ONFIELD end
	if (loc1|loc2)&(LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)>0 then f=aux.DestroyFilter(f) end
	if not min then min=1 end
	if not max then max=min end
	return	function (e,tp,eg,ep,ev,re,r,rp)
				if exc then exc=e:GetHandler() end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local g=Duel.SelectMatchingCard(tp,f,tp,loc1,loc2,min,max,exc,e,tp)
				if #g>0 then
					Duel.HintSelection(g,true)
					local ct=Duel.Destroy(g,REASON_EFFECT)
					return g,ct
				end
				return g,0
			end
end

-----------------------------------------------------------------------
--Search
function Auxiliary.SearchFilter(f)
	return	function(c,...)
				return (not f or f(c,...)) and c:IsAbleToHand()
			end
end
function Auxiliary.SearchTarget(f,min)
	if not min then min=1 end
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.IsExistingMatchingCard(aux.SearchFilter(f),tp,LOCATION_DECK,0,min,nil,e,tp) end
				Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,min,tp,LOCATION_DECK)
			end
end
function Auxiliary.SearchOperation(f,min,max)
	if not min then min=1 end
	if not max then max=min end
	return	function (e,tp,eg,ep,ev,re,r,rp)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local g=Duel.SelectMatchingCard(tp,aux.SearchFilter(f),tp,LOCATION_DECK,0,min,max,nil,e,tp)
				if #g>0 then
					local ct,ht=Duel.Search(g,tp)
					return g:Filter(aux.PLChk,nil,tp,LOCATION_HAND),ct,ht
				end
				return g,0,0
			end
end

-----------------------------------------------
--SELF
--[[
Places counters on itself equal to the number of cards involved in an event, multiplied by (ct)
* (ctype) = Counter type
* (ct) = Default is 1. The number multiplied with the number of cards involved to get the total amount of counters that will be placed
* (f) = Filter for the cards involved in the event. Only the cards that satisfy the filter will be counted for the Counters' placement.
]]
function Auxiliary.EventCounterSelfOperation(ctype,ct,f)
	if not ct then ct=1 end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetHandler()
				local tot=eg:FilterCount(f,nil,e,tp,eg,ep,ev,re,r,rp)*ct
				if tot>0 and c:IsCanAddCounter(ctype,tot,true) then
					c:AddCounter(ctype,tot,true)
				end
			end
end

function Auxiliary.PositionSelfTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanChangePosition() end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
function Auxiliary.PositionSelfOperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsCanChangePosition() then
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end


function Auxiliary.SSSelfTarget(loc_clause)
	if loc_clause~=nil and loc_clause and type(loc_clause)~="table" then loc_clause={LOCATION_GRAVE,LOCATION_HAND} end
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				local c=e:GetHandler()
				if chk==0 then
					return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,true) 																					and (not loc_clause or ((c:IsLocation(loc_clause[1]) and not eg:IsContains(c)) or (c:IsLocation(loc_clause[2]))))
				end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
			end
end
function Auxiliary.SSSelfOperation(complete_proc)
	return	function (e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetHandler()
				if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not c:IsRelateToEffect(e) then return end
				if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
					if complete_proc then
						c:CompleteProcedure()
					end
					return true
				end
				return false
			end
end