--Naval Gears Formation
local cid,id=GetID()
function cid.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--indestructable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetTarget(cid.infilter)
	e2:SetValue(cid.efilter)
	c:RegisterEffect(e2)
		--pos
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4777,3))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetCondition(cid.condition)
	e3:SetTarget(cid.target)
	e3:SetOperation(cid.operation)
	c:RegisterEffect(e3)
		local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(4777,4))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e4:SetCondition(cid.condition)
	e4:SetTarget(cid.target2)
	e4:SetOperation(cid.operation2)
	c:RegisterEffect(e4)
end
function cid.filter(c,e,tp)
	return c:IsSetCard(0x700) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
end
function cid.operation2(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_SZONE,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
function cid.filter2(c,e,tp)
	return c:IsSetCard(0x700) and c:IsType(TYPE_MONSTER)
end
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cid.filter2,tp,LOCATION_MZONE,0,1,nil)
	end
	function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(cid.filter2,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil,e,tp) end
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
if not e:GetHandler():IsRelateToEffect(e) then return end
local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
local g=Duel.SelectMatchingCard(tp,cid.filter2,tp,LOCATION_MZONE+LOCATION_HAND,0,1,ft,nil)
	local tc=g:GetFirst()
	if not tc then return end
	while tc do
	if g:GetCount()>0 then
	option=Duel.SelectOption(tp,aux.Stringid(4777,1),aux.Stringid(4777,2)) end
	if option==1 then 
	Duel.BreakEffect()
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetCode(EFFECT_CHANGE_TYPE)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetReset(RESET_EVENT+0x1fc0000)
    e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
    tc:RegisterEffect(e1)
    Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	tc=g:GetNext()
	end
	if option==0 then
	Duel.BreakEffect()
	local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetCode(EFFECT_CHANGE_TYPE)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetReset(RESET_EVENT+0x1fc0000)
    e2:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
    tc:RegisterEffect(e2)
    Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	tc=g:GetNext()
		
    end
end
end



--indestructable
function cid.infilter(e,c)
	return c:IsSetCard(0x700) and c:GetCode()~=id 
end
function cid.efilter(e,te)
	return not te:GetOwner():IsSetCard(0x700)
end