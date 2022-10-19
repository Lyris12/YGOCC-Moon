GFILTER_TABLE = {aux.dncheck}
GFILTER_DIFFERENT_NAMES = 1

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
function Auxiliary.Target(f,loc1,loc2,min,max,exc,check,info,prechk,necrovalley,...)
	local x={...}
	if not f then f=aux.TRUE end
	if not min then min=1 end
	if not max then max=min end
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=loc1 end
	local locs = (loc1&(~loc2))|loc2
	
	if locs&LOCATION_GRAVE>0 and necrovalley then
		f=aux.NecroValleyFilter(f)
	end
	return	function (e,tp,eg,ep,ev,re,r,rp,chk,chkc)
				local exc= (aux.GetValueType(exc)=="boolean" and exc) and e:GetHandler() or (exc) and exc or nil
				if chkc then
					local plchk=(loc1~=0 and chkc:IsControler(tp) and chkc:IsLocation(loc1) or loc2~=0 and chkc:IsControler(1-tp) and chkc:IsLocation(loc2))
					return plchk and (not f or f(chkc,e,tp,eg,ep,ev,re,r,rp,chk))
				end
				if chk==0 then
					if prechk then prechk(e,tp,eg,ep,ev,re,r,rp) end
					return ((not check or check(e,tp,eg,ep,ev,re,r,rp)) and Duel.IsExistingTarget(f,tp,loc1,loc2,min,exc,e,tp,eg,ep,ev,re,r,rp,chk))
				end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local g=Duel.SelectTarget(tp,f,tp,loc1,loc2,min,max,exc,e,tp,eg,ep,ev,re,r,rp,chk)
				if info then
					if type(info)=="function" then
						info(g,e,tp,eg,ep,ev,re,r,rp)
					elseif type(info)=="table" then
						local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
						Duel.SetCustomOperationInfo(0,info[1],g,#g,p,locs,info[2])
					else
						local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
						Duel.SetOperationInfo(0,info,g,#g,p,locs)
					end
				end
				if #x>0 then
				
					for _,extrainfo in ipairs(x) do
						if type(extrainfo)=="function" then
							extrainfo(g,e,tp,eg,ep,ev,re,r,rp)
						elseif type(extrainfo)=="table" then
							local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
							Duel.SetCustomOperationInfo(0,extrainfo[1],g,#g,p,locs,extrainfo[2])
						else
							local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
							Duel.SetOperationInfo(0,extrainfo,g,#g,p,locs)
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
				local p=(p>1) and p or (p==0) and tp or (p==1) and 1-tp 
				return Duel.SetOperationInfo(0,ctg,nil,ct,p,v)
			end
end
function Auxiliary.DamageInfo(p,v)
	return	function(_,e,tp)
				return Auxiliary.Info(CATEGORY_DAMAGE,0,p,v)
			end
end
function Auxiliary.HandlerInfo(ctg,ct,p,v)
	return	function(_,e,tp)
				local p=(p>1) and p or (p==0) and tp or (p==1) and 1-tp 
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
--Banish
function Auxiliary.BanishFilter(f,cost)
	return	function(c,...)
				return (not f or f(c,...)) and (not cost and c:IsAbleToRemove() or cost and c:IsAbleToRemoveAsCost())
			end
end
function Auxiliary.BanishTarget(f,loc1,loc2,min,exc)
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=LOCATION_ONFIELD end
	if not min then min=1 end
	
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				if exc then exc=e:GetHandler() end
				if chk==0 then return Duel.IsExistingMatchingCard(aux.BanishFilter(f),tp,loc1,loc2,min,exc,e,tp) end
				if loc1>0 and loc2>0 then
					Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,min,PLAYER_ALL,loc1|(loc2&(~loc1)))
				elseif loc1>0 then
					Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,min,tp,loc1)
				elseif loc2>0 then
					Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,min,1-tp,loc1)
				end
			end
end
function Auxiliary.BanishOperation(f,loc1,loc2,min,max,exc)
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=LOCATION_ONFIELD end
	if (loc1|loc2)&LOCATION_GRAVE>0 then f=aux.NecroValleyFilter(f) end
	if not min then min=1 end
	if not max then max=min end
	return	function (e,tp,eg,ep,ev,re,r,rp)
				if exc then exc=e:GetHandler() end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
				local g=Duel.SelectMatchingCard(tp,aux.BanishFilter(f),tp,loc1,loc2,min,max,exc,e,tp)
				if #g>0 then
					Duel.HintSelection(g)
					local ct=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
					return g,ct
				end
				return g,0
			end
end

-----------------------------------------------------------------------
--Damage
function Auxiliary.DamageTarget(ct)
	if not ct then ct=1000 end
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return true end
				Duel.SetTargetPlayer(1-tp)
				Duel.SetTargetParam(ct)
				Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,min)
			end
end
function Auxiliary.DamageOperation()
	return	function (e,tp,eg,ep,ev,re,r,rp)
				local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
				return Duel.Damage(p,d,REASON_EFFECT)
			end
end

-----------------------------------------------------------------------
--Destroy
function Auxiliary.DestroyFilter(f)
	return	function(c,e,...)
				return (not f or f(c,e,...)) and c:IsDestructable(e)
			end
end
function Auxiliary.NotConfirmed(f)
	return	function(c,...)
				return not c:IsPublic() or (not f or f(c,...))
			end
end
function Auxiliary.DestroyTarget(f,loc1,loc2,min,exc)
	if not f then f=aux.TRUE end
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=LOCATION_ONFIELD end
	if not min then min=1 end
	local locs = (loc1&(~loc2))|loc2
	
	if locs&(LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)>0 then
		f=aux.DestroyFilter(f)
		return	function (e,tp,eg,ep,ev,re,r,rp,chk)
					if exc then exc=e:GetHandler() end
					if chk==0 then return Duel.IsExistingMatchingCard(f,tp,loc1,loc2,min,exc,e,tp) end
					local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
					if locs&LOCATION_ONFIELD>0 then
						local g=Duel.GetMatchingGroup(f,tp,loc1,loc2,exc,e,tp)
						if not Duel.IsExistingMatchingCard(aux.NotConfirmed(f),tp,loc1,loc2,min,exc,e,tp) then
							Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,min,p,locs)
						else
							Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,min,p,locs)
						end
					else
						Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,min,p,locs)
					end
				end
	else
		return	function (e,tp,eg,ep,ev,re,r,rp,chk)
					if exc then exc=e:GetHandler() end
					if chk==0 then return Duel.IsExistingMatchingCard(f,tp,loc1,loc2,min,exc,e,tp) end
					local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
					local g=Duel.GetMatchingGroup(f,tp,loc1,loc2,exc,e,tp)
					Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,min,p,locs)
				end
	end
end
function Auxiliary.DestroyOperation(f,loc1,loc2,min,max,exc)
	if not f then f=aux.TRUE end
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=LOCATION_ONFIELD end
	local locs = (loc1&(~loc2))|loc2
	if locs&(LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)>0 then f=aux.DestroyFilter(f) end
	if not min then min=1 end
	if not max then max=min end
	return	function (e,tp,eg,ep,ev,re,r,rp)
				if exc then exc=e:GetHandler() end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local g=Duel.SelectMatchingCard(tp,f,tp,loc1,loc2,min,max,exc,e,tp)
				if #g>0 then
					Duel.HintSelection(g)
					local ct=Duel.Destroy(g,REASON_EFFECT)
					return g,ct
				end
				return g,0
			end
end

-----------------------------------------------------------------------
--Discard
function Auxiliary.DiscardFilter(f,cost)
	local r = (not cost) and REASON_EFFECT or REASON_COST
	return	function(c)
				return (not f or f(c)) and c:IsDiscardable(r)
			end
end
function Auxiliary.DiscardTarget(f,min,max,p)
	if not min then min=1 end
	
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				local p = (not p or p==0) and tp or 1-tp
				if chk==0 then return Duel.IsExistingMatchingCard(aux.DiscardFilter(f),p,LOCATION_HAND,0,min,nil) end
				Duel.SetTargetPlayer(p)
				if not max then
					Duel.SetTargetParam(min)
				end
				Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,p,min)
			end
end
function Auxiliary.DiscardOperation(f,min,max,p)
	if not min then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
					return Duel.DiscardHand(p,aux.DiscardFilter(f),d,d,REASON_EFFECT+REASON_DISCARD)
				end
	else
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
					return Duel.DiscardHand(p,aux.DiscardFilter(f),min,max,REASON_EFFECT+REASON_DISCARD)
				end
	end
end

--Draw
function Auxiliary.DrawTarget(min)
	if not min then min=1 end
	
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.IsPlayerCanDraw(tp,min) end
				Duel.SetTargetPlayer(tp)
				Duel.SetTargetParam(min)
				Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,min)
			end
end
function Auxiliary.DrawOperation()
	return	function (e,tp,eg,ep,ev,re,r,rp)
				local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
				return Duel.Draw(p,d,REASON_EFFECT)
			end
end

-----------------------------------------------------------------------
--Search
function Auxiliary.SearchFilter(f)
	return	function(c,...)
				return (not f or f(c,...)) and c:IsAbleToHand()
			end
end
function Auxiliary.SearchTarget(f,min,loc,max)
	if not min then min=1 end
	if not loc then loc=LOCATION_DECK end
	local gf
	if type(f)=="table" then
		if #f>1 then
			gf=GFILTER_TABLE[f[2]]
		end
		f=f[1]
	end
	local filter=aux.SearchFilter(f)
	
	if not gf or min==1 then
		return	function (e,tp,eg,ep,ev,re,r,rp,chk)
					if chk==0 then return Duel.IsExistingMatchingCard(filter,tp,loc,0,min,nil,e,tp) end
					Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,min,tp,loc)
				end
	else
		return	function (e,tp,eg,ep,ev,re,r,rp,chk)
					local g=Duel.GetMatchingGroup(filter,tp,loc,0,nil,e,tp)
					if chk==0 then return g:CheckSubGroup(filter,min,max,e,tp) end
					Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,min,tp,loc)
				end
	end
end
function Auxiliary.SearchOperation(f,min,max,loc,relcheck)
	if not min then min=1 end
	if not max then max=min end
	if not loc then loc=LOCATION_DECK end
	local gf
	if type(f)=="table" then
		if #f>1 then
			gf=GFILTER_TABLE[f[2]]
		end
		f=f[1]
	end
	local filter=aux.SearchFilter(f)
	if loc&LOCATION_GRAVE>0 then
		filter=aux.NecroValleyFilter(filter)
	end
	if not gf then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					if relcheck and not e:GetHandler():IsRelateToChain() then return end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
					local g=Duel.SelectMatchingCard(tp,filter,tp,loc,0,min,max,nil,e,tp)
					if #g>0 then
						local ct,ht,hg=Duel.Search(g,tp)
						return hg,ct,ht
					end
					return g,0,0
				end
	else
		return	function (e,tp,eg,ep,ev,re,r,rp)
					if relcheck and not e:GetHandler():IsRelateToChain() then return end
					local g=Duel.GetMatchingGroup(filter,tp,loc,0,nil)
					if #g<min then return end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
					local sg=g:SelectSubGroup(tp,gf,false,min,max)
					if #sg>0 then
						local ct,ht,hg=Duel.Search(sg,tp)
						return hg,ct,ht
					end
					return sg,0,0
				end
	end
end

--To Deck
function Auxiliary.ToDeckFilter(f,cost)
	return	function(c,...)
				return (not f or f(c,...)) and (not cost and c:IsAbleToDeck() or cost and c:IsAbleToDeckAsCost())
			end
end

-----------------------------------------------------------------------
--Negates
function Auxiliary.NegateCondition(monstercon,negateact,rplayer,rf,cond)
	local negatecheck = negateact and Duel.IsChainNegatable or Duel.IsChainDisablable
	return	function(e,tp,eg,ep,ev,re,r,rp)
				return (not monstercon or not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED))
					and (not rplayer or (rplayer==0 and rp==tp) or rp==1-tp)
					and (not rf or (type(rf)=="number" and re:IsActiveType(rf)) or rf(re:GetHandler(),re))
					and (not cond or cond(e,tp,eg,ep,ev,re,r,rp))
					and negatecheck(ev)
			end
end
function Auxiliary.NegateTarget(negateact,negatedop,tg)
	local negcategory = negateact and CATEGORY_NEGATE or CATEGORY_DISABLE
	
	if negatedop==0 then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					if chk==0 then
						return not tg or tg(e,tp,eg,ep,ev,re,r,rp,chk)
					end
					if tg then
						tg(e,tp,eg,ep,ev,re,r,rp,chk)
					end
					Duel.SetOperationInfo(0,negcategory,eg,1,0,0)
				end
	elseif negatedop==CATEGORY_DESTROY then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local rc=re:GetHandler()
					local relation=rc:IsRelateToChain(ev)
					if chk==0 then
						return not tg or tg(e,tp,eg,ep,ev,re,r,rp,chk)
					end
					if tg then
						tg(e,tp,eg,ep,ev,re,r,rp,chk)
					end
					Duel.SetOperationInfo(0,negcategory,eg,1,0,0)
					if relation then
						Duel.SetOperationInfo(0,CATEGORY_DESTROY,rc,1,rc:GetControler(),rc:GetLocation())
					else
						Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,rc:GetPreviousControler(),rc:GetPreviousLocation())
					end
				end
	else
		local chktab = {
			[CATEGORY_REMOVE]	={Card.IsAbleToRemove,Duel.IsPlayerCanRemove};
			[CATEGORY_TOHAND]	={function(c) return c:IsAbleToHand() end,Duel.IsPlayerCanSendtoHand};
			[CATEGORY_TOGRAVE]	={function(c) return c:IsAbleToGrave() end,Duel.IsPlayerCanSendtoGrave};
			[CATEGORY_TODECK]	={function(c) return c:IsAbleToDeck() end,Duel.IsPlayerCanSendtoDeck};
		}
		local rcchk,pchk=chktab[negatedop][1],chktab[negatedop][2]
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local rc=re:GetHandler()
					local relation=rc:IsRelateToChain(ev)
					if chk==0 then
						return (rcchk(rc,tp) or (not relation and pchk(tp)))
							and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,chk))
					end
					if tg then
						tg(e,tp,eg,ep,ev,re,r,rp,chk)
					end
					Duel.SetOperationInfo(0,negcategory,eg,1,0,0)
					if relation then
						Duel.SetOperationInfo(0,negatedop,rc,1,rc:GetControler(),rc:GetLocation())
					else
						Duel.SetOperationInfo(0,negatedop,nil,0,rc:GetPreviousControler(),rc:GetPreviousLocation())
					end
				end
	end
end
function Auxiliary.NegateOperation(negateact,negatedop)
	local negtype = negateact and Duel.NegateActivation or Duel.NegateEffect
	if negatedop==0 then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					return negtype(ev)
				end
	else
		local chktab = {
			[CATEGORY_DESTROY]	=Duel.Destroy;
			[CATEGORY_REMOVE]	=function(c,r) return Duel.Remove(c,POS_FACEUP,r) end;
			[CATEGORY_TOHAND]	=function(c,r) return Duel.SendtoHand(c,nil,r) end;
			[CATEGORY_TOGRAVE]	=Duel.SendtoGrave;
			[CATEGORY_TODECK]	=function(c,r) return Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,r) end;
		}
		local action=chktab[negatedop]
		return	function (e,tp,eg,ep,ev,re,r,rp)
					if negtype(ev) and re:GetHandler():IsRelateToChain(ev) then
						return action(eg,REASON_EFFECT)
					end
					return false
				end
	end
end

-----------------------------------------------------------------------
--Special Summons
SPSUM_MOD_NEGATE   = 0x1
SPSUM_MOD_REDIRECT = 0x2

function Auxiliary.SSFilter(f)
	return	function(c,e,tp,...)
				return (not f or f(c,e,tp,...)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			end
end
function Auxiliary.SSTarget(f,loc1,loc2,min,exc)
	if not loc1 then loc1=LOCATION_DECK end
	if not loc2 then loc2=0 end
	local locs = (loc1&(~loc2))|loc2
	if not min then min=1 end
	
	if min==1 then
		return	function (e,tp,eg,ep,ev,re,r,rp,chk)
					if exc then exc=e:GetHandler() end
					if chk==0 then return Duel.GetMZoneCount(tp)>=min and Duel.IsExistingMatchingCard(aux.SSFilter(f),tp,loc1,loc2,min,exc,e,tp) end
					if loc1>0 and loc2>0 then
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,PLAYER_ALL,locs)
					elseif loc1>0 then
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,tp,loc1)
					elseif loc2>0 then
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,1-tp,loc1)
					end
				end
	else
		return	function (e,tp,eg,ep,ev,re,r,rp,chk)
					if exc then exc=e:GetHandler() end
					if chk==0 then
						return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.GetMZoneCount(tp)>=min and Duel.IsExistingMatchingCard(aux.SSFilter(f),tp,loc1,loc2,min,exc,e,tp)
					end
					if loc1>0 and loc2>0 then
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,PLAYER_ALL,locs)
					elseif loc1>0 then
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,tp,loc1)
					elseif loc2>0 then
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,1-tp,loc1)
					end
				end
	end
end
function Auxiliary.SSOperation(f,loc1,loc2,min,max,exc)
	if not loc1 then loc1=LOCATION_DECK end
	if not loc2 then loc2=0 end
	local locs = (loc1&(~loc2))|loc2
	if locs&LOCATION_GRAVE>0 then f=aux.NecroValleyFilter(f) end
	if not min then min=1 end
	if not max then max=min end
	if min==1 and max==1 then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					if Duel.GetMZoneCount(tp)<min then return end
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSFilter(f),tp,loc1,loc2,min,max,exc,e,tp)
					if #g>0 then
						local ct=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
						return Duel.GetOperatedGroup(),ct
					end
					return g,0
				end
	elseif min==1 and max>1 then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local ft=Duel.GetMZoneCount(tp)
					if ft<min then return end
					if ft>max then ft=max end
					if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSFilter(f),tp,loc1,loc2,min,ft,exc,e,tp)
					if #g>0 then
						local ct=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
						return Duel.GetOperatedGroup(),ct
					end
					return g,0
				end
	elseif min>1 and max==min then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetMZoneCount(tp)<min then return end
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSFilter(f),tp,loc1,loc2,min,max,exc,e,tp)
					if #g>0 then
						local ct=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
						return Duel.GetOperatedGroup(),ct
					end
					return g,0
				end
	elseif min>1 and max>min then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local ft=Duel.GetMZoneCount(tp)
					if ft<min or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
					if ft>max then ft=max end
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSFilter(f),tp,loc1,loc2,min,ft,exc,e,tp)
					if #g>0 then
						local ct=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
						return Duel.GetOperatedGroup(),ct
					end
					return g,0
				end
	end
end
function Auxiliary.SSOperationMod(mod,f,loc1,loc2,min,max,exc,...)
	local modvals={...}
	if not mod then mod=SPSUM_MOD_NEGATE end
	local spsum
	if mod==SPSUM_MOD_NEGATE then
		spsum=Duel.SpecialSummonNegate
	elseif mod==SPSUM_MOD_REDIRECT then
		spsum=Duel.SpecialSummonRedirect
	end
	
	if not loc1 then loc1=LOCATION_DECK end
	if not loc2 then loc2=0 end
	local locs = (loc1&(~loc2))|loc2
	if locs&LOCATION_GRAVE>0 then f=aux.NecroValleyFilter(f) end
	if not min then min=1 end
	if not max then max=min end
	if min==1 and max==1 then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					if Duel.GetMZoneCount(tp)<min then return end
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSFilter(f),tp,loc1,loc2,min,max,exc,e,tp)
					if #g>0 then
						local ct=spsum(e,g,0,tp,tp,false,false,POS_FACEUP,table.unpack(modvals))
						return g,ct
					end
					return g,0
				end
	elseif min==1 and max>1 then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local ft=Duel.GetMZoneCount(tp)
					if ft<min then return end
					if ft>max then ft=max end
					if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSFilter(f),tp,loc1,loc2,min,ft,exc,e,tp)
					if #g>0 then
						local ct=spsum(e,g,0,tp,tp,false,false,POS_FACEUP,table.unpack(modvals))
						return g,ct
					end
					return g,0
				end
	elseif min>1 and max==min then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetMZoneCount(tp)<min  then return end
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSFilter(f),tp,loc1,loc2,min,max,exc,e,tp)
					if #g>0 then
						local ct=spsum(e,g,0,tp,tp,false,false,POS_FACEUP,table.unpack(modvals))
						return g,ct
					end
					return g,0
				end
	elseif min>1 and max>min then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local ft=Duel.GetMZoneCount(tp)
					if ft<min or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
					if ft>max then ft=max end
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSFilter(f),tp,loc1,loc2,min,ft,exc,e,tp)
					if #g>0 then
						local ct=spsum(e,g,0,tp,tp,false,false,POS_FACEUP,table.unpack(modvals))
						return g,ct
					end
					return g,0
				end
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
	if loc_clause~=nil and aux.GetValueType(loc_clause)~="table" then loc_clause={LOCATION_GRAVE,LOCATION_HAND} end
	
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				local c=e:GetHandler()
				if chk==0 then
					return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
						and (not loc_clause or ((c:IsLocation(loc_clause[1]) and not eg:IsContains(c)) or (c:IsLocation(loc_clause[2]))))
				end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
			end
end
function Auxiliary.SSSelfOperation(complete_proc)
	return	function (e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetHandler()
				if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not c:IsRelateToChain() then return end
				local ct=Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
				if ct~=0 and complete_proc then
					c:CompleteProcedure()
				end
				return ct
			end
end

-----------------------------------------------
--SPECIAL SUMMON
function Duel.SpecialSummonATK(e,g,styp,sump,tp,ign1,ign2,pos,atk,reset,rc)
	if not reset then reset=0 end
	if not rc then rc=e:GetHandler() end
	if aux.GetValueType(g)=="Card" then
		if g==e:GetHandler() and rc==e:GetHandler() then reset=reset+RESET_DISABLE end
		g=Group.FromCards(g)
	end
	local ct=0
	for dg in aux.Next(g) do
		if Duel.SpecialSummonStep(dg,styp,sump,tp,ign1,ign2,pos) then
			ct=ct+1
			local e1=Effect.CreateEffect(rc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
			dg:RegisterEffect(e1)
		end
	end
	Duel.SpecialSummonComplete()
	return ct
end
function Duel.SpecialSummonNegate(e,g,styp,sump,tp,ign1,ign2,pos,reset,rc)
	if not reset then reset=0 end
	if not rc then rc=e:GetHandler() end
	if aux.GetValueType(g)=="Card" then g=Group.FromCards(g) end
	local ct=0
	for dg in aux.Next(g) do
		if Duel.SpecialSummonStep(dg,styp,sump,tp,ign1,ign2,pos) then
			ct=ct+1
			local e1=Effect.CreateEffect(rc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
			dg:RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(rc)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
			dg:RegisterEffect(e2,true)
		end
	end
	Duel.SpecialSummonComplete()
	return ct
end
function Duel.SpecialSummonRedirect(e,g,styp,sump,tp,ign1,ign2,pos,loc)
	if not loc then loc=LOCATION_REMOVED end
	if aux.GetValueType(g)=="Card" then g=Group.FromCards(g) end
	local ct=0
	for dg in aux.Next(g) do
		if Duel.SpecialSummonStep(dg,styp,sump,tp,ign1,ign2,pos) then
			ct=ct+1
			local e=Effect.CreateEffect(e:GetHandler())
			e:SetType(EFFECT_TYPE_SINGLE)
			e:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e:SetValue(loc)
			e:SetReset(RESET_EVENT+RESETS_REDIRECT_FIELD)
			dg:RegisterEffect(e,true)
		end
	end
	Duel.SpecialSummonComplete()
	return ct
end