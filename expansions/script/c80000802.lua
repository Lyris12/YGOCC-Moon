--Runecrafted Utopia


local cid,id=GetID()

function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcCodeFun(c,80000800,aux.FilterBoolFunction(Card.IsFusionSetCard,0x107f),1,true,true)
	Auxiliary.Add_Runeslots(c,1)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84013237,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1)
	e1:SetOperation(cid.atkop)
	c:RegisterEffect(e1)	
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetCondition(cid.rpcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end

function cid.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateAttack()
	Duel.GainRP(e:GetHandlerPlayer(),400)
end

function cid.rpcon(e,tp,eg,ep,ev,re,r,rp)
	local red = 0x1ff5
	local blue = 0x2ff5
	local purple = 0x3ff5
	local yellow = 0x4ff5
	local orange = 0x5ff5
	local green = 0x6ff5
	local prismatic = 0x7ff5
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,blue)
end
