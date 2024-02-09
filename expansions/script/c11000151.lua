--Nidalee of the Sands
function c11000151.initial_effect(c)
	c:SetUniqueOnField(1,1,11000151)
	--Own Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c11000151.spcon)
	e1:SetOperation(c11000151.spop)
	c:RegisterEffect(e1)
	--Target immune
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetValue(aux.tgoval)
	e2:SetCondition(c11000151.imcon)
	c:RegisterEffect(e2)
	--Indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c11000151.indval)
	e3:SetCondition(c11000151.imcon)
	c:RegisterEffect(e3)
	--Add
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c11000151.thtg)
	e4:SetOperation(c11000151.thop)
	c:RegisterEffect(e4)
end
function c11000151.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end
function c11000151.imfilter(c)
	return c:IsFaceup() and c:IsCode(11000130)
end
function c11000151.imcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and	Duel.IsExistingMatchingCard(c11000151.imfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function c11000151.rfilter(c)
	return c:IsSetCard(0x1F6)
end
function c11000151.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>-1
		and Duel.CheckReleaseGroup(c:GetControler(),c11000151.rfilter,1,nil)
end
function c11000151.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(c:GetControler(),c11000151.rfilter,1,1,nil)
	Duel.Release(g,REASON_COST)
end
function c11000151.thfilter(c)
	return (c:IsCode(11000142) or c:IsCode(11000143) or c:IsCode(11000146)
		or c:IsCode(11000147)) and c:IsAbleToHand()
end
function c11000151.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11000151.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c11000151.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c11000151.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end