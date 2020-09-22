--Gladiator Beast Alexctavius
function c40933345.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcCode2(c,79580323,29357956,false,false)
	--Spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--Special summon rule
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c40933345.sprcon)
	e2:SetOperation(c40933345.sprop)
	c:RegisterEffect(e2)
	--Cannot Activate
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetOperation(c40933345.actop)
	c:RegisterEffect(e3)
	--Equip
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(40933345,0))
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(c40933345.eqtg)
	e4:SetOperation(c40933345.eqop)
	c:RegisterEffect(e4)
	--attack announce
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(40933345,1))
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(c40933345.tdtg)
	e5:SetOperation(c40933345.tdop)
	c:RegisterEffect(e5)
	--special summon
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(40933345,8))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(c40933345.spcon)
	e6:SetCost(c40933345.spcost)
	e6:SetTarget(c40933345.sptg)
	e6:SetOperation(c40933345.spop)
	c:RegisterEffect(e6)
end
function c40933345.spfilter1(c,tp)
	return c:IsFusionCode(79580323) and c:IsAbleToDeckOrExtraAsCost() and c:IsCanBeFusionMaterial(nil,true)
		and Duel.IsExistingMatchingCard(c40933345.spfilter2,tp,LOCATION_ONFIELD,0,1,c)
end
function c40933345.spfilter2(c)
	return c:IsFusionCode(29357956) and c:IsCanBeFusionMaterial() and c:IsAbleToDeckOrExtraAsCost()
end
function c40933345.sprcon(e,c)
	if c==nil then return true end 
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2
		and Duel.IsExistingMatchingCard(c40933345.spfilter1,tp,LOCATION_ONFIELD,0,1,nil,tp)
end
function c40933345.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(40933345,2))
	local g1=Duel.SelectMatchingCard(tp,c40933345.spfilter1,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(40933345,3))
	local g2=Duel.SelectMatchingCard(tp,c40933345.spfilter2,tp,LOCATION_ONFIELD,0,1,1,g1:GetFirst())
	g1:Merge(g2)
	local tc=g1:GetFirst()
	while tc do
		if not tc:IsFaceup() then Duel.ConfirmCards(1-tp,tc) end
		tc=g1:GetNext()
	end
	Duel.SendtoDeck(g1,nil,2,REASON_COST)
end
function c40933345.actop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c40933345.actlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c40933345.actlimit(e,re,tp)
	return not re:GetHandler():IsImmuneToEffect(e)
end
function c40933345.filter(c,tc)
	return c:IsType(TYPE_EQUIP) and c:IsSetCard(0x19)
end
function c40933345.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(c40933345.filter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND)
end
function c40933345.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,c40933345.filter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,c)
	if g:GetCount()==0 and not g:GetFirst():IsHasEffect(EFFECT_NECRO_VALLEY) then return end
 	local sc=g:GetFirst()
 		Duel.Equip(tp,sc,c,true)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		e1:SetValue(c40933345.eqlimit)
		e1:SetLabelObject(c)
		sc:RegisterEffect(e1)
end
function c40933345.eqlimit(e,c)
	return e:GetLabelObject()==c
end
function c40933345.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function c40933345.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	if sg:GetCount()>0 then
		Duel.HintSelection(sg)
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
function c40933345.tgfilter(c)
	return c:IsSetCard(0xbe) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
function c40933345.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end
function c40933345.tdop(e,tp,eg,ep,ev,re,r,rp)
		local sg=nil
		local hg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
		local b1=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil)
		local b2=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil)
		local b3=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil)
		local op=0
		if not b1 and not b2 and not b3 then return end
		if b1 then
			if b2 and b3 then
				op=Duel.SelectOption(tp,aux.Stringid(40933345,4),aux.Stringid(40933345,5),aux.Stringid(40933345,6))
			elseif b2 and not b3 then
				op=Duel.SelectOption(tp,aux.Stringid(40933345,4),aux.Stringid(40933345,5))
			elseif not b2 and b3 then
				op=Duel.SelectOption(tp,aux.Stringid(40933345,4),aux.Stringid(40933345,6))
				if op==1 then op=2 end
			else
				op=0
			end
		else
			if b2 and b3 then
				op=Duel.SelectOption(tp,aux.Stringid(40933345,5),aux.Stringid(40933345,6))+1
			elseif b2 and not b3 then
				op=1
			else
				op=2
			end
		end
		if op==0 then
			sg=hg:RandomSelect(tp,1)
		elseif op==1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
			Duel.HintSelection(sg)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
			Duel.HintSelection(sg)
		end
		Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
	end
function c40933345.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
function c40933345.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	Duel.SendtoDeck(c,nil,0,REASON_COST)
end
function c40933345.spfilter(c,e,tp)
	return c:IsSetCard(0x19) and c:IsCanBeSpecialSummoned(e,120,tp,false,false)
end
function c40933345.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c40933345.spfilter,tp,LOCATION_DECK,0,2,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
function c40933345.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,40933345) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local g=Duel.GetMatchingGroup(c40933345.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>=2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,2,2,nil)
		local tc=sg:GetFirst()
		Duel.SpecialSummonStep(tc,120,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+0x1ff0000,0,0)
		tc=sg:GetNext()
		Duel.SpecialSummonStep(tc,120,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+0x1ff0000,0,0)
		Duel.SpecialSummonComplete()
	end
end

