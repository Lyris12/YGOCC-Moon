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
	e2:SetCondition(s.statcon)
	e2:SetValue(s.statval)
	c:RegisterEffect(e2)
	e2:UpdateDefenseClone(c)
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:OPT()
	e3:SetCost(aux.DummyCost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
function s.tffilter(c,tp,re)
	return c:IsFaceup() and c:IsOnField() and c:IsControler(tp) and c:IsSetCard(ARCHE_DREAMY_FOREST,ARCHE_DREARY_FOREST) and re:GetHandler()==c
end
function s.tfcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	return r&REASON_EFFECT~=0 and eg:IsExists(s.tffilter,1,nil,tp,re)
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

function s.statcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.statval(e,c)
	local ct=e:GetHandler():GetCounter(COUNTER_JOY)
	if ct<0 then ct=0 end
	return ct*100
end

function s.thfilter(c,code)
	return c:IsSetCard(ARCHE_DREAMY_FOREST,ARCHE_DREARY_FOREST) and c:IsAbleToHand() and not c:IsCode(table.unpack(code))
end
function s.tgfilter(c,tp)
	return c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,c,{c:GetCode()})
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local b1=Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
	local b2=e:IsCostChecked() and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,nil,tp)
	if chk==0 then
		return b1 or b2
	end
	local opt=aux.Option(tp,id,2,b1,b2)
	if opt==0 then
		e:SetCategory(0)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	elseif opt==1 then
		e:SetCategory(CATEGORY_TOHAND)
		e:SetProperty(0)
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,nil,tp)
		if #g>0 then
			local codes={g:GetFirst():GetCode()}
			e:SetLabel(table.unpack(codes))
			Duel.SendtoGrave(g,REASON_COST)
		end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	end
	Duel.SetTargetParam(opt)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.GetTargetParam()
	if not opt then return end
	if opt==0 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() then
			local eid=e:GetFieldID()
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,eid,aux.Stringid(id,4))
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetLabel(eid)
			e1:SetLabelObject(tc)
			e1:SetTargetRange(0,1)
			e1:SetValue(1)
			e1:SetCondition(s.actcon)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	elseif opt==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,{e:GetLabel()})
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
function s.actcon(e)
	local tc=e:GetLabelObject()
	if not tc or not tc:HasFlagEffectLabel(id,e:GetLabel()) then
		e:Reset()
		return false
	end
	return Duel.GetAttacker()==tc
end