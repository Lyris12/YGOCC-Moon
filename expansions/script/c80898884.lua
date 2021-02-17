--Runath Master
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end

local id,cid=getID()

function cid.initial_effect(c)
	aux.AddLinkProcedure(c,cid.matfilter,2,3)
	c:EnableReviveLimit()
	Auxiliary.Add_Runeslots(c,2)


	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(cid.yellowcon)
	e1:SetOperation(cid.yellowop)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE)
	e2:SetCondition(cid.redcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(cid.bluecon)
	e3:SetOperation(cid.blueop)
	c:RegisterEffect(e3)
end

function cid.yellowcon(e,tp,eg,ep,ev,re,r,rp)
	local red = 0x1ff5
	local blue = 0x2ff5
	local purple = 0x3ff5
	local yellow = 0x4ff5
	local orange = 0x5ff5
	local green = 0x6ff5
	local prismatic = 0x7ff5
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,2,nil,yellow) and Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>=0
end


function cid.yellowop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.Destroy(g,REASON_EFFECT)
end

function cid.matfilter(c)
	return c:IsType(TYPE_MONSTER)
end


function cid.redcon(e,tp,eg,ep,ev,re,r,rp)
	local red = 0x1ff5
	local blue = 0x2ff5
	local purple = 0x3ff5
	local yellow = 0x4ff5
	local orange = 0x5ff5
	local green = 0x6ff5
	local prismatic = 0x7ff5
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,2,nil,red)
end

function cid.bluecon(e,tp,eg,ep,ev,re,r,rp)
	local red = 0x1ff5
	local blue = 0x2ff5
	local purple = 0x3ff5
	local yellow = 0x4ff5
	local orange = 0x5ff5
	local green = 0x6ff5
	local prismatic = 0x7ff5
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,2,nil,blue)
end

function cid.blueop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(e:GetHandlerPlayer(),2,REASON_EFFECT)
	Duel.BreakEffect()
	Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
end