--Runath Caller
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end

local id,cid=getID()

function cid.initial_effect(c)
	aux.AddLinkProcedure(c,cid.matfilter,1,1)
	c:EnableReviveLimit()
	Auxiliary.Add_Runeslots(c,1)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetOperation(cid.rpop2)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(cid.rpcon)
	e2:SetCost(cid.spcost)
	e2:SetTarget(cid.sptg)
	e2:SetOperation(cid.spop)
	c:RegisterEffect(e2)
end


function cid.matfilter(c)
	return c:IsLinkSetCard(0xff4) and c:GetLink()>=2 and c:IsType(TYPE_LINK)
end

function cid.rpcon(e,tp,eg,ep,ev,re,r,rp)
	local red = 0x1ff5
	local blue = 0x2ff5
	local purple = 0x3ff5
	local yellow = 0x4ff5
	local orange = 0x5ff5
	local green = 0x6ff5
	local prismatic = 0x7ff5
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,yellow)
end

function cid.rpop2(e,tp,eg,ep,ev,re,r,rp)
	local tp = e:GetHandler():GetOwner()
	Duel.GainRP(tp,300)
end

function cid.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end

function cid.filter(c,e,tp)
	return c:IsCode(80898885) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
	Duel.SpecialSummonComplete()
end
