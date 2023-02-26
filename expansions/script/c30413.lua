--Zero HERO Watch Man
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	Duel.RegisterCustomSetCard(c,30401,30419,CUSTOM_ARCHE_ZERO_HERO)
	Card.IsZHERO=Card.IsZHERO or (function(tc) return (tc:GetCode()>30400 and tc:GetCode()<30420) or (tc:IsSetCard(0x8) and tc:IsCustomSetCard(CUSTOM_ARCHE_ZERO_HERO)) end)
	--special summon
	local e0=Effect.CreateEffect(c)
	e0:Desc(0)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_DDD)
	e0:SetCode(EVENT_TO_HAND)
	e0:SetCondition(scard.condition)
	e0:SetTarget(scard.target)
	e0:SetOperation(scard.operation)
	c:RegisterEffect(e0)
	--atk eff
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCondition(scard.cona)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsZHERO))
	e1:SetValue(1000)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--def eff
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(scard.cond)
	e3:SetTarget(scard.tg2)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e4)
end
function scard.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_DECK) and c:GetPreviousControler()==tp
end
function scard.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function scard.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not c:IsRelateToChain() then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end

function scard.cona(e)
	return e:GetHandler():IsAttackPos()
end

function scard.tg2(e,c)
	return c:IsZHERO() and c~=e:GetHandler()
end
function scard.cond(e)
	return e:GetHandler():IsDefensePos()
end
