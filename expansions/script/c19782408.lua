local cid,id=GetID()
--Patmos, The True Administral
function cid.initial_effect(c)
	--Link Procedure
	aux.AddLinkProcedure(c,nil,2,3,cid.lcheck)
	c:EnableReviveLimit()
	--1st Effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(cid.stattg)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
end
function cid.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0xd7c)
end
function cid.stattg(e,c)
	return c:IsSetCard(0xd7c) and c:GetSequence()<5
end