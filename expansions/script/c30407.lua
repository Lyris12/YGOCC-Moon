--Zero HERO Ice Guy
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	Duel.RegisterCustomSetCard(c,30401,30419,CUSTOM_ARCHE_ZERO_HERO)
	Card.IsZHERO=Card.IsZHERO or (function(tc) return (tc:GetCode()>30400 and tc:GetCode()<30420) or (tc:IsSetCard(0x8) and tc:IsCustomSetCard(CUSTOM_ARCHE_ZERO_HERO)) end)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x8),2)
	--Opponent's monsters lose ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(scard.atktg)
	e1:SetValue(scard.atkval)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1x)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(s_id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetTarget(scard.destg)
	e2:SetOperation(scard.desop)
	c:RegisterEffect(e2)
end
function scard.atktg(e,c)
	local lg=e:GetHandler():GetLinkedGroup()
	return lg and lg:IsContains(c)
end
function scard.atkfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(0x8)
end
function scard.atkval(e,c)
	return Duel.GetMatchingGroupCount(scard.atkfilter,e:GetHandlerPlayer(),LOCATION_REMOVED,0,nil)*-500
end

function scard.filter(c,e,tp)
	return c:IsZHERO() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function scard.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(scard.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function scard.desop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,scard.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(STRING_CANNOT_TRIGGER)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
			e1:SetReset(RESET_EVENT|RESET_DISABLE|RESET_PHASE|PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
	Duel.SpecialSummonComplete()
end
