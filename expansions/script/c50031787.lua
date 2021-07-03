--Garbage Beast
local cid,id=GetID()
function cid.initial_effect(c)
	   aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
  aux.AddEvoluteProc(c,nil,2,cid.filter1,1)
--attack up
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x1e0)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
	  --synchro summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e3:SetCondition(cid.sccon)
	e3:SetCost(cid.cost2)
	e3:SetTarget(cid.sctg)
	e3:SetOperation(cid.scop)
	c:RegisterEffect(e3)
end


function cid.filter1(c,ec,tp)
	return c:IsRace(RACE_ROCK) or c:IsAttribute(ATTRIBUTE_FIRE)
end

function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,1,REASON_COST)  end
  
 e:GetHandler():RemoveEC(tp,1,REASON_COST)
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
   
end

function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	 if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		tc:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		tc:RegisterEffect(e3)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		tc:RegisterEffect(e4)
		local e5=e1:Clone()
		e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		tc:RegisterEffect(e5)
		local e6=e1:Clone()
		e6:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		tc:RegisterEffect(e6)
		local e7=e1:Clone()
		e7:SetCode(EFFECT_CANNOT_BE_EVOLUTE_MATERIAL)
		tc:RegisterEffect(e7)
		local e8=e1:Clone()
		e8:SetCode(EFFECT_CANNOT_BE_POLARITY_MATERIAL)
		tc:RegisterEffect(e8)
		local e9=e1:Clone()
		e9:SetCode(EFFECT_CANNOT_BE_SPACE_MATERIAL)
		tc:RegisterEffect(e9)
		local e10=e1:Clone()
		e10:SetCode(EFFECT_CANNOT_BE_BIGBANG_MATERIAL)
		tc:RegisterEffect(e10)
		local e11=e1:Clone()
		e11:SetCode(EFFECT_CANNOT_BE_SPATIAL_MATERIAL)
		tc:RegisterEffect(e11)  
		local e12=e1:Clone()
		e12:SetCode(EFFECT_CANNOT_BE_HARMONIZED_MATERIAL)
		tc:RegisterEffect(e12)
		local e13=e1:Clone()
		e13:SetCode(EFFECT_CANNOT_BE_BYPATH_MATERIAL)
		tc:RegisterEffect(e13)
		local e14=e1:Clone()
		e14:SetCode(EFFECT_CANNOT_BE_TIMELEAP_MATERIAL)
		tc:RegisterEffect(e14)
		local e15=e1:Clone()
		e15:SetCode(EFFECT_CANNOT_HAVE_CHROMA_MATERIAL)
		tc:RegisterEffect(e15)
		local e16=e1:Clone()
		e16:SetCode(EFFECT_CANNOT_BE_ANNOTEE_MATERIAL)
		tc:RegisterEffect(e16)
		local e17=e1:Clone()
		e17:SetCode(EFFECT_CANNOT_BE_ACCENTED_MATERIAL)
		tc:RegisterEffect(e17)
		local e18=e1:Clone()
		e18:SetCode(EFFECT_CANNOT_BE_ACCENTED_MATERIAL)
		tc:RegisterEffect(e18)
	end
end
function cid.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
function cid.sccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT)))
		and c:IsPreviousPosition(POS_FACEUP)
end
function cid.filter(c,e,tp)
	return c:IsSetCard(0x66) and c:IsLevelBelow(8) and c:IsType(TYPE_SYNCHRO)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function cid.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
   if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,sg,sg:GetCount(),0,0)
end
function cid.scop(e,tp,eg,ep,ev,re,r,rp)
	  local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SendtoGrave(sg,REASON_EFFECT)
end


