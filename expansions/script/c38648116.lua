--Elyria, la Città Coperta
--Script by XGlitchy30
function c38648116.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--stats boost
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xe841))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e2x=Effect.CreateEffect(c)
	e2x:SetType(EFFECT_TYPE_FIELD)
	e2x:SetCode(EFFECT_UPDATE_DEFENSE)
	e2x:SetRange(LOCATION_FZONE)
	e2x:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2x:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xe841))
	e2x:SetValue(300)
	c:RegisterEffect(e2x)
	--protection
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(c38648116.immunecon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--swap pendulum monsters
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(38648116,0))
	e4:SetCategory(CATEGORY_TOEXTRA)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(2)
	e4:SetTarget(c38648116.swaptg)
	e4:SetOperation(c38648116.swapop)
	c:RegisterEffect(e4)
end
--filters
function c38648116.immunefilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_NORMAL)
end
function c38648116.swapfilter1(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xe841) and c:IsType(TYPE_PENDULUM)
		and Duel.IsExistingMatchingCard(c38648116.swapfilter2,tp,LOCATION_EXTRA,0,1,c,c:GetCode())
end
function c38648116.swapfilter2(c,code)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xe841) and c:GetCode()~=code
end
--protection
function c38648116.immunecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c38648116.immunecon,tp,LOCATION_MZONE,0,1,nil)
end
--swap pendulum monsters
function c38648116.swaptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and c38648116.swapfilter1(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(c38648116.swapfilter1,tp,LOCATION_PZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(18210764,1))
	local g=Duel.SelectTarget(tp,c38648116.swapfilter1,tp,LOCATION_PZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
function c38648116.swapop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if Duel.SendtoExtraP(tc,tp,REASON_EFFECT)~=0 then
			local seq=Duel.GetOperatedGroup():GetFirst():GetPreviousSequence()
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(76794549,6))
			local g=Duel.SelectMatchingCard(tp,c38648116.swapfilter2,tp,LOCATION_EXTRA,0,1,1,tc,tc:GetCode())
			local swap=g:GetFirst()
			if swap then
				Duel.MoveToField(swap,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
				Duel.MoveSequence(swap,seq)
			end
		end
	end
end