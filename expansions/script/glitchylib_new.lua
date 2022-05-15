--Custom Categories
CATEGORY_ZONE		  				= 0x1
CATEGORY_DISABLE_ZONE 				= 0x2
CATEGORY_PLACE_AS_CONTINUOUS_TRAP	= 0x4
CATEGORY_REDIRECT_ATTACK			= 0x8
CATEGORY_SET						= 0x10
CATEGORY_ACTIVATE					= 0x20

--constants aliases
TYPE_ST			= TYPE_SPELL+TYPE_TRAP

ARCHE_FUSION	= 0x46

LOCATION_ALL = LOCATION_DECK+LOCATION_HAND+LOCATION_MZONE+LOCATION_SZONE+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA	

RESET_TURN_SELF = RESET_SELF_TURN
RESET_TURN_OPPO = RESET_OPPO_TURN
RESETS_STANDARD_EXC_GRAVE = RESETS_STANDARD&~(RESET_LEAVE|RESET_TOGRAVE)


--Shortcuts
function Duel.IsExists(target,tp,f,loc1,loc2,min,exc,...)
	if type(target)~="boolean" then return false end
	local func = (target==true) and Duel.IsExistingTarget or Duel.IsExistingMatchingCard
	
	return func(f,tp,loc1,loc2,min,exc,...)
end
function Duel.Select(target,tp,hint,f,loc1,loc2,min,max,exc,...)
	if type(target)~="boolean" then return false end
	local func = (target==true) and Duel.SelectTarget or Duel.SelectMatchingCard
	local hint = hint or HINTMSG_TARGET
	
	Duel.Hint(HINT_SELECTMSG,tp,hint)
	local g=func(tp,f,tp,loc1,loc2,min,max,exc,...)
	return g
end
function Duel.Group(f,tp,loc1,loc2,exc,...)
	local g=Duel.GetMatchingGroup(f,tp,loc1,loc2,exc,...)
	return g
end

--Custom Categories
if not global_effect_category_table_global_check then
	global_effect_category_table_global_check=true
	global_effect_category_table={}
	global_effect_info_table={}
end
function Effect.SetCustomCategory(e,cat)
	if not global_effect_category_table[e] then global_effect_category_table[e]={} end
	table.insert(global_effect_category_table[e],cat)
end
function Duel.SetCustomOperationInfo(ch,cat,g,ct,p,val)
	if not global_effect_info_table[ch+1] or #global_effect_info_table[ch+1]>0 then
		global_effect_info_table[ch+1]={}
	end
	table.insert(global_effect_info_table[ch+1],{cat,g,ct,p,val})
end

--Card Actions
function Duel.Negate(tc,e,reset)
	if not reset then reset=0 end
	Duel.NegateRelatedChain(tc,RESET_TURN_SET)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	tc:RegisterEffect(e2)
	if tc:IsType(TYPE_TRAPMONSTER) then
		local e=Effect.CreateEffect(e:GetHandler())
		e:SetType(EFFECT_TYPE_SINGLE)
		e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e:SetCode(EFFECT_DISABLE_TRAPMONSTER)
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
		tc:RegisterEffect(e)
	end
	return e1,e2
end
function Duel.NegateInGY(tc,e,reset)
	if not reset then reset=0 end
	Duel.NegateRelatedChain(tc,RESET_TURN_SET)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_EXC_GRAVE+reset)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD_EXC_GRAVE+reset)
	tc:RegisterEffect(e2)
	return e1,e2
end
function Duel.PositionChange(c)
	return Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
end
function Duel.Search(g,tp)
	local ct=Duel.SendtoHand(g,nil,REASON_EFFECT)
	local cg=g:Filter(aux.PLChk,nil,tp,LOCATION_HAND)
	if #cg>0 then
		Duel.ConfirmCards(1-tp,cg)
	end
	return ct,#cg
end

--Card Filters
function Card.IsMonster(c,typ)
	return c:IsType(TYPE_MONSTER) and (not typ or c:IsType(typ))
end
function Card.IsST(c,typ)
	return c:IsType(TYPE_ST) and (not typ or c:IsType(typ))
end

function Card.HasAttack(c)
	return true
end
function Card.HasDefense(c)
	return not c:IsOriginalType(TYPE_LINK)
end
function Card.HasOriginalLevel(c)
	return not c:IsOriginalType(TYPE_XYZ+TYPE_LINK)
end

function Card.ByBattleOrEffect(c,f,p)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				return c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and (not f or re and f(re:GetHandler(),e,tp,eg,ep,ev,re,r,rp)) and (not p or rp~=(1-p))
			end
end

--Chain Info
function Duel.GetTargetParam()
	return Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
end

--Descriptions
function Effect.Desc(e,id,...)
	local x = {...}
	local code = #x>0 and x[1] or e:GetOwner():GetOriginalCode()
	return e:SetDescription(aux.Stringid(code,id))
end

function Auxiliary.Option(id,tp,desc,...)
	local list={...}
	local off=1
	local ops={}
	local opval={}
	local truect=1
	for ct,b in ipairs(list) do
		local check=b
		local localid=id
		local localdesc=desc+truect-1
		if type(b)=="table" then
			check=b[1]
			localid=b[2]
			localdesc=b[3]
		else
			truect=truect+1
		end
		if check==true then
			ops[off]=aux.Stringid(localid,localdesc)
			opval[off]=ct-1
			off=off+1
		end
	end
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	Duel.Hint(HINT_OPSELECTED,1-tp,ops[op])
	return sel
end

--Flag Effects
function Card.HasFlagEffect(c,id)
	return c:GetFlagEffect(id)>0
end
function Duel.UpdateFlagEffectLabel(p,id,ct)
	if not ct then ct=1 end
	return Duel.SetFlagEffectLabel(p,id,Duel.GetFlagEffectLabel(p,id)+ct)
end

--Gain Effect
function Auxiliary.GainEffectType(c,oc,reset)
	if not oc then oc=c end
	if not reset then reset=0 end
	if not c:IsType(TYPE_EFFECT) then
		local e=Effect.CreateEffect(oc)
		e:SetType(EFFECT_TYPE_SINGLE)
		e:SetCode(EFFECT_ADD_TYPE)
		e:SetValue(TYPE_EFFECT)
		e:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e,true)
	end
end

--Locations
function Card.IsBanished(c)
	return c:IsLocation(LOCATION_REMOVED)
end
function Card.IsInExtra(c)
	return c:IsLocation(LOCATION_EXTRA)
end
function Card.NotBanishedOrFaceup(c)
	return not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup()
end
function Card.NotInExtraOrFaceup(c)
	return not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup()
end

function Auxiliary.PLChk(c,p,loc)
	if type(c)=="Card" then
		return (not p or c:IsControler(p)) and (not loc or c:IsLocation(loc))
	elseif type(c)=="Group" then
		return c:IsExists(aux.PLChk,1,nil,p,loc)
	else
		return false
	end
end
function Auxiliary.AfterShuffle(g)
	for p=0,1 do
		if g:IsExists(aux.PLChk,1,nil,p,LOCATION_DECK) then
			Duel.ShuffleDeck(p)
		end
	end
end
--Phases
function Duel.IsDrawPhase(tp)
	return (not tp or Duel.GetTurnPlayer()==tp) and Duel.GetCurrentPhase()==PHASE_DRAW
end
function Duel.IsStandbyPhase(tp)
	return (not tp or Duel.GetTurnPlayer()==tp) and Duel.GetCurrentPhase()==PHASE_STANDBY
end
function Duel.IsMainPhase(tp,ct)
	return (not tp or Duel.GetTurnPlayer()==tp) and (not ct and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2) or ct==1 and Duel.GetCurrentPhase()==PHASE_MAIN1 or ct==2 and Duel.GetCurrentPhase()==PHASE_MAIN2)
end
function Duel.IsBattlePhase(tp)
	local ph=Duel.GetCurrentPhase()
	return (not tp or Duel.GetTurnPlayer()==tp) and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function Duel.IsEndPhase(tp)
	return (not tp or Duel.GetTurnPlayer()==tp) and Duel.GetCurrentPhase()==PHASE_END
end

--SS
function Duel.SpecialSummonRedirect(e,g,styp,sump,tp,ign1,ign2,pos,loc)
	if not loc then loc=LOCATION_REMOVED end
	if type(g)=="Card" then g=Group.FromCards(g) end
	local ct=0
	for dg in aux.Next(g) do
		if Duel.SpecialSummonStep(dg,styp,sump,tp,ign1,ign2,pos) then
			ct=ct+1
			local e=Effect.CreateEffect(e:GetHandler())
			e:SetType(EFFECT_TYPE_SINGLE)
			e:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e:SetValue(loc)
			e:SetReset(RESET_EVENT+RESETS_REDIRECT)
			dg:RegisterEffect(e,true)
		end
	end
	Duel.SpecialSummonComplete()
	return ct
end

-----------------------------------------------------------------------
function Card.Ignition(c,desc,ctg,prop,range,ctlim,cond,cost,tg,op)
	local range = range and range or (c:IsOriginalType(TYPE_MONSTER)) and LOCATION_MZONE or (c:IsOriginalType(TYPE_FIELD)) and LOCATION_FZONE
	---
	local e1=Effect.CreateEffect(c)
	if desc then
		e1:Desc(desc)
	end
	if ctg then
		e1:SetCategory(ctg)
	end
	if prop~=nil then
		e1:SetProperty(prop)
	end	
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(range)
	if ctlim then
		if type(ctlim)=="table" then
			local flag=#ctlim>2 and ctlim[3] or 0
			e1:SetCountLimit(ctlim[1],c:GetOriginalCode()+ctlim[2]*100+flag)
		else
			e1:SetCountLimit(ctlim)
		end
	end
	if cond then
		e1:SetCondition(cond)
	end
	if cost then
		e1:SetCost(cost)
	end
	if tg then
		e1:SetTarget(tg)
	end
	if op then
		e1:SetOperation(op)
	end
	c:RegisterEffect(e1)
	return e1
end
function Card.Quick(c,forced,desc,ctg,prop,event,range,ctlim,cond,cost,tg,op)
	if not event then event=EVENT_FREE_CHAIN end
	local range = range or (c:IsOriginalType(TYPE_MONSTER)) and LOCATION_MZONE or (c:IsOriginalType(TYPE_FIELD)) and LOCATION_FZONE
	local quick_type=(not forced) and EFFECT_TYPE_QUICK_O or EFFECT_TYPE_QUICK_F
	---
	local e1=Effect.CreateEffect(c)
	if desc then
		e1:Desc(desc)
	end
	if ctg then
		e1:SetCategory(ctg)
	end
	if prop~=nil then
		if type(prop)=="boolean" and prop==true then
			e1:SetProperty(EFFECT_FLAG_DELAY)
		else
			e1:SetProperty(prop)
		end
	end	
	e1:SetType(quick_type)
	e1:SetCode(event)
	e1:SetRange(range)
	if ctlim then
		if type(ctlim)=="table" then
			local flag=#ctlim>2 and ctlim[3] or 0
			e1:SetCountLimit(ctlim[1],c:GetOriginalCode()+ctlim[2]*100+flag)
		else
			e1:SetCountLimit(ctlim)
		end
	end
	if cond then
		e1:SetCondition(cond)
	end
	if cost then
		e1:SetCost(cost)
	end
	if tg then
		e1:SetTarget(tg)
	end
	if op then
		e1:SetOperation(op)
	end
	c:RegisterEffect(e1)
	return e1
end