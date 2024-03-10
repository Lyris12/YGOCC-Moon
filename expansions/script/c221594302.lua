--created by Walrus, coded by XGlitchy30
--Voidictator Servant - Gate Architect
local s,id=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	local p1=Effect.CreateEffect(c)
	p1:SetType(EFFECT_TYPE_FIELD)
	p1:SetCode(EFFECT_DISABLE)
	p1:SetRange(LOCATION_PZONE)
	p1:SetTargetRange(0,LOCATION_MZONE|LOCATION_PZONE)
	p1:SetCondition(s.discon)
	p1:SetTarget(s.disable)
	c:RegisterEffect(p1)
	local p2=Effect.CreateEffect(c)
	p2:Desc(0)
	p2:SetCategory(CATEGORY_TODECK|CATEGORY_DRAW)
	p2:SetType(EFFECT_TYPE_IGNITION)
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
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_DRAW)
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
	local pc=Duel.GetPendulums(tp,c)
	return pc and pc:IsFaceup() and pc:IsCode(CARD_VOIDICTATOR_SERVANT_GATE_SORCERESS)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,ARCHE_VOIDICTATOR_DEITY,ARCHE_VOIDICTATOR_DEMON),tp,LOCATION_MZONE,0,1,nil)
end
function s.disable(e,c)
	return not c:IsLocation(LOCATION_MZONE) or (c:IsType(TYPE_PENDULUM) and (c:IsType(TYPE_EFFECT) or (c:GetOriginalType()&TYPE_EFFECT)==TYPE_EFFECT))
end
function s.cfilter(c)
	return c:IsSetCard(ARCHE_VOIDICTATOR) and c:IsAbleToRemoveAsCost()
end
function s.rescon(g,e,tp)
	local ct=#g
	return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND|LOCATION_ONFIELD,0,ct,g) and Duel.IsPlayerCanDraw(tp,ct), not Duel.IsPlayerCanDraw(tp,ct)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then
		return e:IsCostChecked() and aux.SelectUnselectGroup(g,e,tp,1,3,s.rescon,0)
	end
	local rg=aux.SelectUnselectGroup(g,e,tp,1,3,s.rescon,1,tp,HINTMSG_REMOVE,nil,nil,false)
	local ct=Duel.Remove(rg,POS_FACEUP,REASON_COST)
	e:SetLabel(ct)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,ct,tp,LOCATION_HAND|LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
	if ct==3 then
		Duel.SetAdditionalOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	end
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	if ct==0 then return end
	local tg=Duel.Select(HINTMSG_TODECK,false,tp,Card.IsAbleToDeck,tp,LOCATION_HAND|LOCATION_ONFIELD,0,ct,ct,nil)
	if #tg>0 then
		ct=Duel.ShuffleIntoDeck(tg,nil,nil,nil,nil,aux.BecauseOfThisEffect(e))
		if ct>0 then
			local ct2=Duel.Draw(tp,ct,REASON_EFFECT)
			if ct2==3 then
				local tg2=Duel.Select(HINTMSG_TODECK,false,tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
				if #tg2>0 then
					Duel.ShuffleHand(tp)
					Duel.BreakEffect()
					Duel.SendtoDeck(tg2,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
				end
			end
		end
	end
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
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,3,nil) and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_TODECK,false,tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,3,3,nil)
	if #g>0 then
		Duel.HintSelection(g)
		if Duel.ShuffleIntoDeck(g)>0 then
			Duel.Draw(tp,1,REASON_EFFECT)
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
