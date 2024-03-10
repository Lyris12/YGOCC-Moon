--created by Walrus, coded by XGlitchy30
--Voidictator Servant - Gate Sorceress
local s,id=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	local p1=Effect.CreateEffect(c)
	p1:SetType(EFFECT_TYPE_FIELD)
	p1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	p1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	p1:SetRange(LOCATION_PZONE)
	p1:SetTargetRange(0,1)
	p1:SetCondition(s.discon)
	p1:SetTarget(s.splimit)
	c:RegisterEffect(p1)
	local p2=Effect.CreateEffect(c)
	p2:Desc(0)
	p2:SetCategory(CATEGORY_RECOVER)
	p2:SetType(EFFECT_TYPE_IGNITION)
	p2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	p2:SetRange(LOCATION_PZONE)
	p2:OPT()
	p2:SetCost(aux.DummyCost)
	p2:SetTarget(s.tdtg)
	p2:SetOperation(s.tdop)
	c:RegisterEffect(p2)
	aux.CannotBeEDMaterial(c,nil,LOCATION_ONFIELD,true)
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND|LOCATION_EXTRA)
	e1:HOPT(true)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetCategory(CATEGORY_REMOVE|CATEGORIES_ATKDEF)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:HOPT()
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
	local e3=Effect.CreateEffect(c)
	e3:Desc(3)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:HOPT()
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
end
function s.discon(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,ARCHE_VOIDICTATOR_DEITY,ARCHE_VOIDICTATOR_DEMON),tp,LOCATION_MZONE,0,1,nil)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	local hc=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	local pc=Duel.GetPendulums(tp,hc)
	return (c:IsLocation(LOCATION_HAND|LOCATION_GRAVE) and c:IsControler(1-tp) and not c:IsLevelBelow(4))
		or (pc and pc:IsFaceup() and pc:IsCode(CARD_VOIDICTATOR_SERVANT_GATE_ARCHITECT) and (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:IsCostChecked() and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
	end
	local ct=Duel.DiscardHand(tp,nil,1,3,REASON_DISCARD|REASON_COST)
	local val=ct*400
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(val)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,val)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local p,val=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,val,REASON_EFFECT)
end
function s.hspfilter(c,ft,tp,sc,loc)
	return c:IsSetCard(ARCHE_VOIDICTATOR_SERVANT) and (c:IsControler(tp) or c:IsFaceup())
		and ((loc&LOCATION_EXTRA==0 and Duel.GetMZoneCount(tp,c)>0) or (loc&LOCATION_EXTRA==LOCATION_EXTRA and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0))
end
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroupEx(tp,s.hspfilter,1,REASON_SPSUMMON,false,nil,ft,tp,c,c:GetLocation())
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.SelectReleaseGroupEx(tp,s.hspfilter,1,1,REASON_SPSUMMON,false,nil,ft,tp,c,c:GetLocation())
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
function s.rmcheck(c,e)
	return c:IsFaceup() and c:IsSetCard(ARCHE_VOIDICTATOR) and aux.BecauseOfThisEffect(e)(c)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetDecktopGroup(tp,3)
	if chk==0 then return rg:FilterCount(Card.IsAbleToRemove,nil)==3 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,3,tp,LOCATION_DECK)
	local c=e:GetHandler()
	Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,c,1,tp,LOCATION_MZONE,400)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DEFCHANGE,c,1,tp,LOCATION_MZONE,200)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetDecktopGroup(tp,3)
	if #g>0 then
		Duel.DisableShuffleCheck()
		if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 and c:IsFaceup() and c:IsRelateToChain() then
			local og=Duel.GetOperatedGroup():Filter(s.rmcheck,nil,e)
			local oc=og:GetClassCount(Card.GetCode)
			if oc==0 then return end
			c:UpdateATKDEF(oc*400,oc*200,true,c)
		end
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and aux.CheckArchetypeReasonEffect(s,re,ARCHE_VOIDICTATOR) and rc:IsOwner(tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return (Duel.CheckPendulumZones(tp) and c:CheckUniqueOnField(tp,LOCATION_PZONE) and not c:IsForbidden()) or c:IsAbleToDeck() end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,c,1,tp,LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		local b1=Duel.CheckPendulumZones(tp) and c:CheckUniqueOnField(tp,LOCATION_PZONE) and not c:IsForbidden()
		local b2=c:IsAbleToDeck()
		local opt=aux.Option(tp,nil,nil,{b1,STRING_PLACE_IN_PZONE},{b2,STRING_SEND_TO_DECK})
		if opt==0 then
			Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		else
			Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
