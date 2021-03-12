--Zero HERO Cyclone Man
--Automate ID
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local scard=_G[str]
	local s_id=tonumber(string.sub(str,2))
	return scard,s_id
end

local scard,s_id=getID()

function scard.initial_effect(c)
	Card.IsZHERO=Card.IsZHERO or (function(tc) return (tc:GetCode()>30400 and tc:GetCode()<30420) and tc:IsSetCard(0x8) end)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x8),2,2)
	--atk limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(scard.atlimit)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(scard.disatkcon)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(scard.disatk)
	c:RegisterEffect(e2)
	--GY SS
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(s_id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(scard.condition)
	e3:SetTarget(scard.target)
	e3:SetOperation(scard.operation)
	c:RegisterEffect(e3)
end
function scard.atlimit(e,c)
	if not Duel.GetAttacker() then return end
	if Duel.GetAttacker():IsZHERO() then
		return false
	else
		return not (c:IsFaceup() and c:IsZHERO())
	end
end
function scard.disatkfil(c)
	return c:IsFaceup() and c:IsZHERO()
end
function scard.disatkcon(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetTurnPlayer()
	local ct=Duel.GetMatchingGroupCount(scard.disatkfil,p,0,LOCATION_MZONE,nil)
	return ct==0
end
function scard.disatk(e,c)
	return not (c:IsFaceup() and c:IsZHERO())
end
function scard.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
function scard.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(scard.filter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,scard.filter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g:GetFirst(),1,tp,LOCATION_GRAVE)
end
function scard.filter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsZHERO()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function scard.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
