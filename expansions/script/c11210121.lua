--Idolominescente Magnum Opus
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--cannot be target/battle indestructable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x5a3))
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--stats
	c:UpdateATKDEFField(s.val(100),s.val(100),false,LOCATION_MZONE,0,nil,s.cond(11111305))
	c:UpdateATKDEFField(s.val(-100),s.val(-100),false,0,LOCATION_MZONE,nil,s.cond(11111306))
	--ss
	c:Ignition(1,CATEGORY_SPECIAL_SUMMON,0,nil,{1,0,EFFECT_COUNT_CODE_DUEL},s.spcon,nil,s.sptg,s.spop)
end
function s.val(n)
	return	function(e,c)
				return Duel.GetFieldGroupCount(0,LOCATION_ONFIELD,LOCATION_ONFIELD)*n
			end
end
function s.filter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function s.cond(code)
	return	function(e)
				return Duel.IsExists(false,s.filter,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,nil,code)
			end
end

function s.spcon(e,tp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.spfilter(c,e,tp)
	return c:IsCode(11111301) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end