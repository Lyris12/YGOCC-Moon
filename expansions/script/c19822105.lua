--created by Seth, coded by Lyris
--Shadow NOVA - Fare
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetDescription(1116)
	e1:SetCondition(function(_,tp) return Duel.GetAttacker():IsControler(1-tp) and s.con(e1,tp) end)
	e1:SetCost(s.cost)
	e1:SetOperation(Duel.NegateAttack)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetDescription(1131)
	e2:SetCondition(aux.AND(function(_,_,_,_,ev) return Duel.IsChainNegatable(ev) end,s.con))
	e2:SetTarget(s.ntg)
	e2:SetOperation(function(_,_,_,_,ev) Duel.NegateActivation(ev) end)
	c:RegisterEffect(e2)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o*10)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCost(s.scost)
	e2:SetTarget(s.stg)
	e2:SetOperation(s.sop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(function() c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,1) end)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_DISABLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xe1f))
	e4:SetCondition(s.scon)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetCategory(CATEGORY_TOHAND)
	e6:SetCondition(s.scon)
	e6:SetCost(function() e6:SetLabel(100) return true end)
	e6:SetTarget(s.tg)
	e6:SetOperation(s.op)
	c:RegisterEffect(e6)
	if not s.global_check then
		s.global_check=true
		if not s.spsum_effects then s.spsum_effects={e4,e5,e6}
		else table.insert(s.spsum_effects,e4) table.insert(s.spsum_effects,e5) table.insert(s.spsum_effects,e6) end
	end
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,2,nil,0xe1f)
end
function s.ntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
end
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xe1f) and c:IsAbleToGraveAsCost()
end
function s.scost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST)
end
function s.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.sop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(e,0,tp,tp,false,false,POS_FACEUP) end
end
function s.scon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
function s.dfilter(c,tp)
	return c:IsSetCard(0xe1f) and c:IsAbleToDeckAsCost() and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
end
function s.filter(c,code)
	return c:IsSetCard(0xe1f) and c:IsAbleToHand() and not c:IsCode(code)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local l=e:GetLabel()==100
	if chk==0 then e:SetLabel(0) return l and Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	Duel.ConfirmCards(1-tp,g)
	e:SetLabelObject(g:GetFirst():GetCode())
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,1,1,nil,e:GetLabelObject():GetCode())
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
end
