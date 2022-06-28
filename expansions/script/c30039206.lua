--Levelution Nebula
local ref=_G['c'..30039206]
function c30039206.initial_effect(c)
	c:EnableReviveLimit()
	--immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c30039206.efilter)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(ref.spcon)
	e2:SetOperation(ref.spop)
	c:RegisterEffect(e2)
	--spsummon condition
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e3)
	--cannot release
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_UNRELEASABLE_SUM)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e5)
	--spsummon
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e6)
	
	--cell sp
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(30039206,0))
	e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetCountLimit(1,30039206)
	e7:SetRange(LOCATION_HAND)
	e7:SetCost(c30039206.cost)
	e7:SetTarget(c30039206.target)
	e7:SetOperation(c30039206.operation)
	c:RegisterEffect(e7)
	end
	
	
function c30039206.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:GetOwner()~=e:GetOwner()
end


function c30039206.spfilter(c,code)
	local code1,code2=c:GetOriginalCodeRule()
	return code1==code or code2==code
end
function ref.matfilter(c,tp)
	return c:IsSetCard(0x93f) and Duel.IsPlayerCanRelease(tp,c)
end
function ref.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local mg=Duel.GetMatchingGroup(ref.matfilter,tp,LOCATION_MZONE,0,nil,tp)
	return mg:CheckWithSumEqual(Card.GetLevel,e:GetHandler():GetLevel(),2,64,tp)
end
function ref.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local mg=Duel.GetReleaseGroup(tp)
	local g=mg:SelectWithSumEqual(tp,Card.GetLevel,e:GetHandler():GetLevel(),2,64)
	Duel.Release(g,REASON_COST)
end

function c30039206.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end

function c30039206.filter(c)
	return c:IsCode(30039201)
end

function c30039206.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(c30039206.filter,tp,LOCATION_DECK,0,1,nil) end
	end
	
function c30039206.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,c30039206.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()~=0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	