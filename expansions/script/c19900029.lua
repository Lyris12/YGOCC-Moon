--Geneseed Cherryvern
local cid,id=GetID()
function cid.initial_effect(c)
c:EnableReviveLimit()
   aux.AddOrigConjointType(c)
	aux.EnableConjointAttribute(c,1)
	   aux.AddOrigEvoluteType(c)
	 aux.AddEvoluteProc(c,nil,5,aux.OR(cid.filter1,cid.filter2),2,99)  
	 --spsummon
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e0:SetCountLimit(1,id)
	e0:SetTarget(cid.sumtg)
	e0:SetOperation(cid.sumop)
	c:RegisterEffect(e0) 
 --atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cid.condtion)
	e1:SetValue(cid.atkval)
	c:RegisterEffect(e1)
end



function cid.filter1(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) 
end
function cid.filter2(c,ec,tp)
	return c:IsRace(RACE_PLANT) 
end

function cid.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x57b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
   if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cid.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(cid.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,cid.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function cid.sumop(e,tp,eg,ep,ev,re,r,rp)
	 local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

function cid.condtion(e)
	local ph=Duel.GetCurrentPhase()
	if not (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) then return false end
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return (a==e:GetHandler() and d and d:IsFaceup())
		or (d==e:GetHandler() )
end

function cid.atkval(e,c)
	return c:GetEC()*200
end