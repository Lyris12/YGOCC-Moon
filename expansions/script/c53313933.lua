--Dragocavaliere Misterioso
--Script by XGlitchy30
function c53313933.initial_effect(c) 
	aux.AddOrigPandemoniumType(c)
	--placeholder
	local e0=Effect.CreateEffect(c)
	c:RegisterEffect(e0)
	--PANDEMONIUM EFFECTS
	--activate pandemonium
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53313933,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(aux.PandActCheck)
	e1:SetCost(c53313933.actcost)
	e1:SetTarget(c53313933.acttg)
	e1:SetOperation(c53313933.actop)
	c:RegisterEffect(e1)
	--spsummon xyz
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53313933,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetLabelObject(e0)
	e2:SetCondition(aux.PandActCheck)
	e2:SetCost(c53313933.spcost)
	e2:SetTarget(c53313933.sptg)
	e2:SetOperation(c53313933.spop)
	c:RegisterEffect(e2)
	aux.EnablePandemoniumAttribute(c,e1,e2)
	--MONSTER EFFECTS
	--spsummon proc
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetDescription(aux.Stringid(53313933,2))
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c53313933.spsumcon)
	e3:SetOperation(c53313933.spsumop)
	c:RegisterEffect(e3)
	--stats boost
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xcf6))
	e4:SetValue(c53313933.statsval)
	c:RegisterEffect(e4)
	local e4x=e4:Clone()
	e4x:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4x)
	--cannot be tributed
	local e4y=Effect.CreateEffect(c)
	e4y:SetType(EFFECT_TYPE_FIELD)
	e4y:SetCode(EFFECT_UNRELEASABLE_SUM)
	e4y:SetRange(LOCATION_MZONE)
	e4y:SetTargetRange(LOCATION_MZONE,0)
	e4y:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xcf6))
	e4y:SetValue(1)
	c:RegisterEffect(e4y)
	local e4yx=e4y:Clone()
	e4yx:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e4yx)
	--level change
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(53313933,3))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,53313933)
	e5:SetTarget(c53313933.lvtg)
	e5:SetOperation(c53313933.lvop)
	c:RegisterEffect(e5)
	--mill
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(53313933,4))
	e6:SetCategory(CATEGORY_TOGRAVE)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_REMOVE)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e6:SetCountLimit(1,50313933)
	e6:SetTarget(c53313933.tgtg)
	e6:SetOperation(c53313933.tgop)
	c:RegisterEffect(e6)
end
--filters
function c53313933.costfilter(c)
	return c:IsFaceup() and c:IsLocation(LOCATION_REMOVED) and c:IsSetCard(0xcf6) and c:IsAbleToDeckAsCost()
end
function c53313933.hfcost(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		and ((c:IsLocation(LOCATION_HAND) and Duel.IsExistingMatchingCard(c53313933.hfcost,tp,LOCATION_MZONE,0,1,c,e,tp))
			or (c:IsLocation(LOCATION_MZONE) and Duel.GetLocationCountFromEx(tp,tp,c)>0 and Duel.IsExistingTarget(c53313933.matchtg,tp,LOCATION_MZONE,0,1,c,e,tp)))
end
function c53313933.matchtg(c,e,tp)
	local val=0
	if c:GetLevel()>0 then
		val=c:GetLevel()
	elseif c:GetRank()>0 then
		val=c:GetRank()
	else
		val=0
	end
	return c:IsFaceup() and c:IsSetCard(0xcf6) and c:IsType(TYPE_MONSTER) and val>0 and c:IsCanBeEffectTarget(e)
		and Duel.IsExistingMatchingCard(c53313933.spfilter,tp,LOCATION_EXTRA,0,1,c,e,tp,c:GetRace(),val)
end
function c53313933.spfilter(c,e,tp,race,val)
	return c:IsType(TYPE_XYZ) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetRace()==race and c:GetRank()==val+1
end
function c53313933.actfilter(c,tp,cc)
	return c:IsSetCard(0xcf6) and c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM and Duel.GetLocationCount(tp,LOCATION_SZONE)>-1 and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
		and not c:IsForbidden() and not Duel.IsExistingMatchingCard(c53313933.excfilter,tp,LOCATION_SZONE,0,1,c,cc)
end
function c53313933.excfilter(c,cc)
	return c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM and c:IsFaceup() and c:GetFlagEffect(726)>0 and (cc==nil or c~=cc)
end
function c53313933.spsumfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0xcf6) and c:IsAbleToDeckAsCost()
end
function c53313933.lvfilter1(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:GetLevel()>0
		and Duel.IsExistingTarget(c53313933.lvfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE,1,c,c:GetLevel())
end
function c53313933.lvfilter2(c,lv)
	return c:IsFaceup() and ((c:GetLevel()>0 and c:GetLevel()~=lv) or (c:GetRank()>0 and c:GetRank()~=lv))
end
function c53313933.tgfilter(c)
	return c:IsSetCard(0xcf6) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
--activate pandemonium
function c53313933.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c53313933.costfilter,tp,LOCATION_REMOVED,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,c53313933.costfilter,tp,LOCATION_REMOVED,0,2,2,nil)
	if g:GetCount()==2 then
		Duel.HintSelection(g)
		Duel.SendtoDeck(g,nil,2,REASON_COST)
	end
end
function c53313933.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c53313933.actfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,tp,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function c53313933.actop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or Duel.IsExistingMatchingCard(c53313933.excfilter,tp,LOCATION_SZONE,0,1,nil) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c53313933.actfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,tp,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.HintSelection(g)
			Card.SetCardData(tc,CARDDATA_TYPE,TYPE_TRAP+TYPE_CONTINUOUS)
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			if not tc:IsLocation(LOCATION_SZONE) then
				Card.SetCardData(tc,CARDDATA_TYPE,tc:GetOriginalType())
			else
				tc:RegisterFlagEffect(726,RESET_EVENT+0x1fe0000,EFFECT_FLAG_CANNOT_DISABLE,1)
				tc:RegisterFlagEffect(725,RESET_PHASE+PHASE_END,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1)
			end
		end
	end
end
--spsummon xyz
function c53313933.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:GetLabelObject():SetLabel(100)
	return true
end
function c53313933.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		if e:GetLabelObject():GetLabel()~=100 then return false end
		e:GetLabelObject():SetLabel(0)
		return Duel.IsExistingMatchingCard(c53313933.hfcost,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	local g=Group.CreateGroup()
	g:KeepAlive()
	for i=1,2 do
		local loc=0
		if i==1 then loc=LOCATION_HAND else loc=LOCATION_MZONE end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g1=Duel.SelectMatchingCard(tp,c53313933.hfcost,tp,loc,0,1,1,nil,e,tp)
		if g1:GetCount()<=0 then
			break
		end
		g:AddCard(g1:GetFirst())
	end	
	if g:GetCount()<=1 then return end
	if Duel.Remove(g,POS_FACEUP,REASON_COST)>1 and Duel.IsExistingTarget(c53313933.matchtg,tp,LOCATION_MZONE,0,1,nil,e,tp) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local tc=Duel.SelectTarget(tp,c53313933.matchtg,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
		if tc then
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		end
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
function c53313933.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	if Duel.GetLocationCountFromEx(tp)>0 then
		local race=tc:GetOriginalRace()
		local val=0
		if tc:GetLevel()>0 then
			val=tc:GetLevel()
		elseif tc:GetRank()>0 then
			val=tc:GetRank()
		else
			val=0
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,c53313933.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,race,val)
		local sp=g:GetFirst()
		if sp then
			Duel.Overlay(sp,tc)
			Duel.SpecialSummon(sp,0,tp,tp,false,false,POS_FACEUP)
			if e:GetHandler():IsAbleToRemove() then
				Duel.BreakEffect()
				Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end
--spsummon proc
function c53313933.spsumcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c53313933.spsumfilter,tp,LOCATION_REMOVED,0,1,c)
end
function c53313933.spsumop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,c53313933.spsumfilter,tp,LOCATION_REMOVED,0,1,1,c)
	Duel.HintSelection(g)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
--stats boost
function c53313933.statsval(e,c)
	return Duel.GetMatchingGroupCount(aux.TRUE,c:GetControler(),LOCATION_REMOVED,LOCATION_REMOVED,nil)*50
end
--level change
function c53313933.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(c53313933.lvfilter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g1=Duel.SelectTarget(tp,c53313933.lvfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	e:SetLabelObject(g1:GetFirst())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c53313933.lvfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE,1,1,nil,g1:GetFirst():GetLevel())
end
function c53313933.lvop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	local sc=g:GetNext()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or sc:IsFacedown() or not sc:IsRelateToEffect(e) then return end
	local ac=e:GetLabelObject()
	if tc==ac then tc=sc end
	local val=tc:GetLevel()
	if tc:GetLevel()>0 then
		val=tc:GetLevel()
	elseif tc:GetRank()>0 then
		val=tc:GetRank()
	else
		val=0
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(val)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	ac:RegisterEffect(e1)
end
--mill
function c53313933.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c53313933.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c53313933.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c53313933.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end