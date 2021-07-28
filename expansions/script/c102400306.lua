--created by Meed, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DISABLE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=Duel.GetDecktopGroup(tp,1):GetFirst()
	if chk==0 then return rc:IsAbleToRemove(tp,POS_FACEDOWN) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,0,0)
end
function s.filter(c,n,tp)
	if n==0x1 then return c:IsAbleToRemove(tp,POS_FACEDOWN)
	else return aux.NegateAnyFilter(c) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	Duel.ConfirmDecktop(tp,1)
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)==0 then return end
	local typ=tc:GetType()&0x7
	if typ&0x3>0 then
		Duel.Hint(HINT_SELECTMSG,tp,typ==0x1 and HINTMSG_REMOVE or HINTMSG_DISABLE)
		local sc=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_ONFIELD,1,1,nil,typ,tp):GetFirst()
		if sc then Duel.BreakEffect() if typ==0x1 then Duel.Remove(sc,POS_FACEDOWN,REASON_EFFECT) else
			Duel.NegateRelatedChain(sc,RESET_TURN_SET)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			sc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			sc:RegisterEffect(e2)
			if sc:IsType(TYPE_TRAPMONSTER) then
				local e3=e1:Clone()
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				sc:RegisterEffect(e3)
			end
		end end
	else Duel.Remove(Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,1),POS_FACEUP,REASON_EFFECT) end
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsType),tp,LOCATION_REMOVED,0,nil,TYPE_MONSTER)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsType),tp,LOCATION_REMOVED,0,nil,TYPE_MONSTER),REASON_EFFECT+REASON_RETURN)
end
