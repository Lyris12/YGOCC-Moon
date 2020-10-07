--Felgrandrise Vier
--Scripted by: XGlitchy30 & Lyris
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	--halve stats
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(cid.atkcon)
	e1:SetTarget(cid.atktg)
	e1:SetOperation(cid.atkop)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetTarget(cid.sptg)
	e2:SetOperation(cid.spop)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,cid.spfilter)
	--equip
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(cid.eqtg)
	e3:SetOperation(cid.eqop)
	c:RegisterEffect(e3)
	local e3x=Effect.CreateEffect(c)
	e3x:SetDescription(aux.Stringid(id,3))
	e3x:SetCategory(CATEGORY_EQUIP)
	e3x:SetType(EFFECT_TYPE_QUICK_O)
	e3x:SetRange(LOCATION_HAND)
	e3x:SetCode(EVENT_FREE_CHAIN)
	e3x:SetCountLimit(1,id)
	e3x:SetCost(cid.eqcost)
	e3x:SetTarget(cid.eqtg)
	e3x:SetOperation(cid.eqop)
	c:RegisterEffect(e3x)
end
cid.FELGRAND={1639384,3954901,6075801,33460840,60681103}
--HALVE STATS
function cid.filter(c)
	return c:IsFaceup() and (c:GetAttack()>0 or c:GetDefense()>0)
end
-------------
function cid.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipGroup()
	return ec:IsExists(function (c) return c:IsFaceup() and c:GetOriginalType()&TYPE_MONSTER>0 end,1,nil)
end
function cid.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function cid.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) then
		Duel.HintSelection(g)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(math.ceil(tc:GetDefense()/2))
		tc:RegisterEffect(e2)
	end
end
--SPECIAL SUMMON
function cid.cfilter(c)
	return (c:IsSetCard(0xfe9) or c:IsCode(table.unpack(cid.FELGRAND)))
		and c:IsAbleToGraveAsCost() and not c:IsCode(id)
end
function cid.spfilter(c)
	return c:IsSetCard(0xfe9) or c:IsCode(table.unpack(cid.FELGRAND))
end
----------------
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_COST)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE)
	and c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
--EQUIP
function cid.efilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and (c:IsSetCard(0xfe9) or c:IsCode(table.unpack(cid.FELGRAND)))
end
function cid.eqfilter(c,tp)
	return c:IsLevel(7,8) and c:CheckUniqueOnField(tp) and c:IsType(TYPE_MONSTER) and c:IsRace(RACE_DRAGON) and not c:IsForbidden()
end
--------
function cid.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function cid.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(cid.efilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(cid.eqfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function cid.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,cid.efilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not tc or tc:IsFacedown() or not tc:IsLocation(LOCATION_MZONE) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local ec=Duel.SelectMatchingCard(tp,cid.eqfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
	if ec then
		Duel.Equip(tp,ec,tc)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(cid.eqlimit)
		e1:SetLabelObject(tc)
		ec:RegisterEffect(e1)
	end
end
function cid.eqlimit(e,c)
	return c==e:GetLabelObject()
end