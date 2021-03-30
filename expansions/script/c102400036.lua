--created & coded by Lyris, art found by meedogh
--スターリ・アイズ・スぺーシュル・ドラゴン
local s,id=GetID()
s.spt_other_space=id+1
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigSpatialType(c)
	aux.AddSpatialProc(c,nil,7,aux.TRUE,2,2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOGRAVE)
	e1:SetCondition(function() return Duel.GetCurrentPhase()==PHASE_MAIN1 end)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsFaceup() and chkc:IsType(TYPE_MONSTER) and aux.nzatk(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.AND(Card.IsFaceup,aux.nzatk,Card.IsType),tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,TYPE_MONSTER) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectTarget(tp,aux.AND(Card.IsFaceup,aux.nzatk,Card.IsType),tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,TYPE_MONSTER):GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tc:GetOwner(),tc:GetAttack())
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tc,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Damage(tc:GetOwner(),tc:GetAttack(),REASON_EFFECT)>0 then
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
	end
end
