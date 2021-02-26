--Tortraveller - Dortokastle
local s,id=GetID()
function s.initial_effect(c)
--pos
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(10110003,0))
e1:SetCategory(CATEGORY_POSITION)
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
e1:SetCode(EVENT_SUMMON_SUCCESS)
e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
e1:SetOperation(c10110003.posop)
c:RegisterEffect(e1)
--Activate
local e2=Effect.CreateEffect(c)
e2:SetCategory(CATEGORY_DRAW+CATEGORY_SUMMON)
e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
e2:SetCode(EVENT_CHANGE_POS)
e2:SetCountLimit(1,10110003)
e2:SetCondition(c10110003.thcon)
e2:SetTarget(c10110003.target)
e2:SetOperation(c10110003.activate)
c:RegisterEffect(e2)
end
function c10110003.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
function c10110003.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsStatus(STATUS_CONTINUOUS_POS) and c:IsPosition(POS_FACEUP_DEFENSE) and c:IsPreviousPosition(POS_FACEUP_ATTACK)
end
function c10110003.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c10110003.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,1,REASON_EFFECT)~=0 then
		local tc=Duel.GetOperatedGroup():GetFirst()
		if tc:IsSetCard(0x4a5) and tc:IsSummonable(true,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(10110003,0)) then
			Duel.BreakEffect()
			Duel.Summon(tp,tc,true,nil)
		end
	end
end
