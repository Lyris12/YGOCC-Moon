--Cosmolight Universe
function c212330.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atk/def up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2500))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--draw
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EVENT_RELEASE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1)
	e4:SetCondition(c212330.drcon)
	e4:SetOperation(c212330.drop)
	c:RegisterEffect(e4)
	--replace
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_ONFIELD,0)
	e5:SetCountLimit(1)
	e5:SetTarget(c212330.indtg)
	e5:SetValue(c212330.indval)
	c:RegisterEffect(e5)
end
function c212330.cfilter(c,tp)
	return c:IsPreviousSetCard(0x2500) and c:GetPreviousTypeOnField()&TYPE_MONSTER>0 and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==tp
end
function c212330.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c212330.cfilter,1,nil,tp)
end
function c212330.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,212330)
	Duel.Hint(HINT_CARD,1-tp,212330)
	Duel.Draw(tp,1,REASON_EFFECT)
end
function c212330.indtg(e,c)
	return c:IsSetCard(0x2500)
end
function c212330.indval(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end