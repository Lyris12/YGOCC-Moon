--created by Slick, coded by Lyris
--Kronologistics Tune Duelist
local s,id,o = GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddSynchroMixProcedure(c,nil,nil,nil,aux.NonTuner(nil),1,99,s.mchk)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCondition(s.con)
	e1:SetValue(s.lvval)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.con)
	e2:SetValue(s.imval)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetCondition(aux.NOT(s.con))
	e3:SetCost(s.ngcost)
	e3:SetTarget(s.ngtg)
	e3:SetOperation(s.ngop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:HOPT()
	e4:SetCondition(s.con)
	e4:SetTarget(s.cntg)
	e4:SetOperation(s.cnop)
	c:RegisterEffect(e4)
	aux.RegisterMergedDelayedEvent(c,id,EVENT_SPSUMMON_SUCCESS)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_CUSTOM+id)
	e5:SetRange(LOCATION_MZONE)
	e5:HOPT()
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetDescription(1105)
	e5:SetCategory(CATEGORY_DISABLE+CATEGORY_TODECK)
	e5:SetCondition(s.tdcon)
	e5:SetTarget(s.tdtg)
	e5:SetOperation(s.tdop)
	c:RegisterEffect(e5)
end
function s.mchk(g)
	return g:IsExists(Card.IsType,1,nil,TYPE_DRIVE)
end
function s.con(e,c)
	return Duel.GetEngagedCard(e:GetHandler():GetControler())~=nil
end
function s.lvval(e,c)
	return Duel.GetEngagedCard(c:GetControler()):GetEnergy()
end
function s.imval(e,te)
	if not te:IsActiveType(TYPE_MONSTER) or te:GetOwnerPlayer()~=tp then return end
	local lv={e:GetHandler():GetLevel(),Duel.GetEngagedCard(e:GetOwnerPlayer()):GetLevel()}
	local ec=te:GetOwner()
	if ec:IsType(TYPE_TIMELEAP) then
		return ec:IsFuture(table.unpack(lv))
	elseif ec:IsType(TYPE_XYZ) then
		return ec:IsRank(table.unpack(lv))
	else
		return ec:IsLevel(table.unpack(lv))
	else return false end
end
function s.cfilter(c)
	return c:IsType(TYPE_DRIVE) and not c:IsPublic()
end
function s.ngcost(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.SetTargetCard(g)
end
function s.ngtg(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return e:IsCostChecked() end
end
function s.ngop(e,tp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then tc:Engage(e,tp) end
end
function s.cntg(_,tp,_,_,_,_,_,_,chk)
	local tc=Duel.GetEngagedCard(tp)
	if chk==0 then for i=1,3 do
		if tc:IsCanIncreaseOrDecreaseEnergy(i,tp,REASON_EFFECT) then return true end
	end end
	Duel.SetTargetCard(tc)
end
function s.cnop(e,tp)
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e)) then return end
	local t={}
	for _,i in ipairs{-3,-2,-1,1,2,3} do if tc:IsCanUpdateEnergy(i,tp,REASON_EFFECT) then table.insert(t,i) end end
	tc:UpdateEnergy(Duel.AnnounceNumber(tp,table.unpack(t)),tp,REASON_EFFECT,RESET_EVENT+RESETS_STANDARD,e:GetHandler(),e)
end
function s.cfilter(c,lv)
	return c:IsFaceup() and (c:IsLevel(lv) or c:IsRank(lv) or c:IsFuture(lv))
end
function s.tdcon(e,_,eg)
	return eg:IsExists(s.cfilter,1,nil,e:GetHandler():GetLevel())
end
function s.filter(c)
	return aux.NegateMonsterFilter(c) and c:IsAbleToDeck()
end
function s.tdtg(e,_,eg,_,_,_,_,_,chk)
	local g=eg:Filter(s.cfilter,nil,e:GetHandler():GetLevel())
	if chk==0 then return g:IsExists(s.filter,1,nil) end
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:FilterCount(s.filter,nil),0,0)
end
function s.tdop(e)
	local c=e:GetHandler()
	local g=Group.CreateGroup()
	for tc in aux.Next(Duel.GetTargetsRelateToChain()) do
		if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			g:AddCard(tc)
		end
	end
	if #g<1 then return end
	Duel.BreakEffect()
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
