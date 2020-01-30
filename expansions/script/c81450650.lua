--Creation Paladin
function c81450650.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,aux.FilterEqualFunction(Card.GetVibe,1),1,aux.FilterEqualFunction(Card.GetVibe,-1),1)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c81450650.val)
	c:RegisterEffect(e1)
	--ATK Down
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetHintTiming(TIMING_DAMAGE_STEP)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c81450650.atktg)
	e4:SetOperation(c81450650.atkop)
	c:RegisterEffect(e4)
	--special summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(34471458,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetTarget(c81450650.sptg)
	e4:SetOperation(c81450650.spop)
	c:RegisterEffect(e4)
end
function c81450650.val(e,c)
	return e:GetHandler():GetMaterialCount()*200
end
function c81450650.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetSummonType()==SUMMON_TYPE_SPECIAL then
		local ct=c:GetMaterialCount()
		c:RegisterFlagEffect(81450650,RESET_EVENT+0x1fe0000,0,0,ct*200)
	end
end
function c81450650.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function c81450650.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(c81450650.atkval)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
	end
end
function c81450650.atkval(e,c)
	if c:IsType(TYPE_XYZ) then
		return c:GetRank()*-200
	else
		return c:GetLevel()*-200
	end
end
function c81450650.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler()
	local mg=tc:GetMaterial()
	if chk==0 then return tc:IsSummonType(SUMMON_TYPE_SPECIAL+340) and mg:IsExists(c81450650.mgfilter,1,nil,e,tp,tc) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function c81450650.mgfilter(c,e,tp,bc)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
		and c:GetReason()&REASON_BIGBANG==REASON_BIGBANG and c:GetReasonCard()==bc
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c81450650.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler()
	local mg=tc:GetMaterial()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=mg:FilterSelect(tp,aux.NecroValleyFilter(c81450650.mgfilter),1,1,nil,e,tp,tc)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
