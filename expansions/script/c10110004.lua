--Tortraveller - Fortuga
local s,id=GetID()
function s.initial_effect(c)
--pos
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(10110004,0))
e1:SetCategory(CATEGORY_POSITION)
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
e1:SetCode(EVENT_SUMMON_SUCCESS)
e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
e1:SetOperation(c10110004.posop)
c:RegisterEffect(e1)
--adchange
local e2=Effect.CreateEffect(c)
e2:SetDescription(aux.Stringid(96146814,0))
e2:SetCategory(CATEGORY_POSITION)
e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
e2:SetCountLimit(1,10110004)
e2:SetCode(EVENT_CHANGE_POS)
e2:SetTarget(c10110004.target)
e2:SetOperation(c10110004.operation)
c:RegisterEffect(e2)
end
function c10110004.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
 end
function c10110004.filter(c)
	 return c:IsSetCard(0x4a5) and c:IsCanChangePosition()
 end
function c10110004.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	 if chkc then return chkc:IsLocation(LOCATION_MZONE) and c10110004.filter(chkc) end
	 if chk==0 then return Duel.IsExistingTarget(c10110004.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	 local g=Duel.SelectTarget(tp,c10110004.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	 Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
 end
function c10110004.operation(e,tp,eg,ep,ev,re,r,rp)
	 local tc=Duel.GetFirstTarget()
	 if tc:IsRelateToEffect(e) then
		 Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	 local tc=Duel.GetFirstTarget()
	 if tc:IsRelateToEffect(e) then
		 Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		end
	end
end