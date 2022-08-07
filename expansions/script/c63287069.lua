--Coppa della Vittoria
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_REMOVE+CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.toss_coin=true

function s.confilter(c)
	if not c:IsReason(REASON_BATTLE) then return end
	if c:IsPreviousLocation(LOCATION_ONFIELD) then
		return c:IsPreviousLocation(LOCATION_MZONE) or c:GetPreviousTypeOnField()&TYPE_MONSTER>0 and c:IsPreviousPosition(POS_FACEUP)
	else
		return c:IsMonster()
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.confilter,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,aux.ActivateException(e))
	end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local res=Duel.TossCoin(tp,1)
	if res==1 then
		Duel.Recover(tp,2000,REASON_EFFECT)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ActivateException(e,1))
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
