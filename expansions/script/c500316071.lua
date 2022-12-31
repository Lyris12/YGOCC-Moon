--Coins of Mercy
function c500316071.initial_effect(c)
c:EnableCounterPermit(0x88)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,500316071+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c500316071.target)
	e1:SetOperation(c500316071.activate)
	c:RegisterEffect(e1)
   --to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(aux.exccon)
e2:SetCountLimit(1,500316071+EFFECT_COUNT_CODE_OATH)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c500316071.sptg)
	e2:SetOperation(c500316071.spop)
	c:RegisterEffect(e2)
end
function c500316071.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EVOLUTE) and c:GetEC()
end
function c500316071.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c500316071.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c500316071.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(500316071,1))
	Duel.SelectTarget(tp,c500316071.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
	 Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,1000)
end

function c500316071.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:RefillEC() then
  Duel.BreakEffect()
		Duel.Recover(1-tp,1000,REASON_EFFECT)
		end
	end

function c500316071.spfilter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function c500316071.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local mg=e:GetHandler():GetReasonCard():GetMaterial()
	if chkc then return mg:IsContains(chkc) and c500316071.spfilter(chkc,e,tp) and chkc~=c end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and mg:IsExists(c500316071.spfilter,1,c,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=mg:FilterSelect(tp,c500316071.spfilter,1,1,c,e,tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c500316071.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

