--created by Hoshi, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetDescription(1127)
	e2:SetCountLimit(1)
	e2:SetCategory(CATEGORY_DICE+CATEGORY_RELEASE+CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_REMOVE+CATEGORY_TODECK)
	e2:SetTarget(s.eftg)
	e2:SetOperation(s.efop)
	c:RegisterEffect(e2)
end
s.toss_dice=true
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dc=Duel.TossDice(tp,1)
	if dc==1 then
		Duel.Damage(tp,500,REASON_EFFECT)
	elseif c:IsRelateToEffect(e) then
		if dc==2 then
			Duel.Release(c,REASON_EFFECT)
		elseif dc==3 then
			Duel.Destroy(c,REASON_EFFECT)
		elseif dc==4 then
			Duel.SendtoHand(c,nil,REASON_EFFECT)
		elseif dc==5 then
			Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
		else
			Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
		end
	end
end
