--created & coded by Swag
--Dreamy Forest, Joyous World
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	c:EnableCounterPermit(COUNTER_JOY)
	c:Activate()
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TRANSFORMED)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(aux.PreTransformationCheckSuccess)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	aux.AddPreTransformationCheck(c,e1,s.tfcon)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(aux.AND(aux.LocationGroupCond(s.cfilter,LOCATION_MZONE,0,1),aux.TurnPlayerCond(0)))
	e2:SetValue(s.statval)
	c:RegisterEffect(e2)
	local e2x=e2:UpdateDefenseClone(c)
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1, EFFECT_COUNT_CODE_SINGLE)
	e3:SetTarget(s.armtg)
	e3:SetOperation(s.armop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:Desc(2)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1, EFFECT_COUNT_CODE_SINGLE)
	e4:SetCost(s.thcost)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsCanAddCounter(COUNTER_JOY,1) then
		c:AddCounter(COUNTER_JOY,1)
	end
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_DREAMY_FOREST)
end
function s.statval(e,c)
	local ct=e:GetHandler():GetCounter(COUNTER_JOY)
	if ct<0 then ct=0 end
	return ct*100
end
function s.armtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.armop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ATTACK_ANNOUNCE)
		e1:SetOperation(s.atkop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end
function s.thfilter(c,code)
	return (c:IsSetCard(ARCHE_DREAMY_FOREST) or c:IsSetCard(ARCHE_DREARY_FOREST))  and c:IsAbleToHand() and not c:IsCode(table.unpack(code))
end
function s.tgfilter(c,tp)
	return c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,{c:GetCode()})
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,tp) end
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,tp)
	Duel.SendtoGrave(g,REASON_COST)
	codes={g:GetFirst():GetCode()}
	e:SetLabel(table.unpack(codes))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,{e:GetLabel()})
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.tffilter(c,tp,re)
	return c:IsFaceup() and c:IsOnField() and c:IsControler(tp) and c:IsSetCard(ARCHE_DREAMY_FOREST,ARCHE_DREARY_FOREST) and re:GetHandler()==c
end
function s.tfcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	return r&REASON_EFFECT~=0 and eg:IsExists(s.tffilter,1,nil,tp,re)
end
