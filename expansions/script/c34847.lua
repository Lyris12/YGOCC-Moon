--Padrona del Cielo
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	--Drive Effects
	aux.AddDriveProc(c,6)
	local d1=c:DriveEffect(0,nil,nil,EFFECT_TYPE_FIELD,EFFECT_FLAG_IGNORE_IMMUNE,EFFECT_CANNOT_BE_EFFECT_TARGET,nil,nil,{LOCATION_MZONE,0,aux.TargetBoolFunction(Card.IsType,TYPE_DRIVE)},1)
	local d2=c:DriveEffect(0,0,nil,EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F,nil,EVENT_PHASE+PHASE_END,aux.TurnPlayerCond(),nil,aux.Check(),s.enop)
	local d3=c:OverDriveEffect(1,CATEGORY_SEARCH+CATEGORY_TOHAND,EFFECT_TYPE_IGNITION,nil,nil,nil,nil,s.thtg,s.thop)
	--SS
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DDD)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--protection
	local e2=Effect.CreateEffect(c)
	e2:Desc(3)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DDD)
	e2:HOPT()
	e2:SetCondition(s.ptcon)
	e2:SetTarget(s.pttg)
	e2:SetOperation(s.ptop)
	c:RegisterEffect(e2)
end
function s.enop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsEngaged() and c:IsCanUpdateEnergy(-2,tp,REASON_EFFECT) then
		c:UpdateEnergy(-2,tp,REASON_EFFECT)
	end
end

function s.filter(c)
	return c:IsMonster(TYPE_DRIVE) and c:IsEnergyAbove(10) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFacedown() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

function s.ptcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_FUSION and e:GetHandler():IsLocation(LOCATION_GRAVE)
end
function s.ptfilter(c)
	return c:IsFaceup() and c:IsMonster(TYPE_FUSION)
end
function s.pttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.ptfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.ptfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.ptfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.ptop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsFaceup() then
		tc:EffectProtection(false,{RESET_PHASE+PHASE_END,2},c)
		tc:TargetProtection(false,{RESET_PHASE+PHASE_END,2},c)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,2,0,aux.Stringid(id,4))
	end
end