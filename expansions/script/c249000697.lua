--Arcane-Transcend Xyz Paladin
function c249000697.initial_effect(c)
	c:EnableReviveLimit()
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	--spsum success
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c249000697.sptg)
	e2:SetOperation(c249000697.spop)
	c:RegisterEffect(e2)
	--material
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19310321,0))
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(c249000697.cost)
	e3:SetTarget(c249000697.target2)
	e3:SetOperation(c249000697.operation2)
	c:RegisterEffect(e3)
end
function c249000697.filter(c,e,sp)
	return c:GetLevel() > 0 and c:GetLevel() <=7 and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
function c249000697.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c249000697.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c249000697.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c249000697.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

function c249000697.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e2)
		--xyzlv
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_XYZ_LEVEL)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetReset(RESET_EVENT+0x1fe0000)
		e3:SetValue(tc:GetOriginalLevel())
		tc:RegisterEffect(e3)
		--xyz summon
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_SPSUMMON_PROC_G)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	 	e4:SetReset(RESET_EVENT+0x1fe0000)
		e4:SetRange(LOCATION_MZONE)
		e4:SetCondition(c249000697.spcon2)
		e4:SetOperation(c249000697.spop2)
		tc:RegisterEffect(e4)	
	end
	Duel.SpecialSummonComplete()
end
function c249000697.xyzfilter(c,c2,e,tp)
	local returnval=false
	local c3
	local g=Group.CreateGroup()
	local i=0
	for key,value in pairs(global_card_effect_table[c]) do
		local etemp=value
		if etemp and etemp:GetDescription()==1165 and etemp:GetCondition() then
			local conf=etemp:GetCondition()
			for i=0,5 do
			 	c3=Debug.AddCard(c2:GetOriginalCode(),tp,tp,0,nil,true)
			 	g:AddCard(c3)
			end
			returnval=conf(etemp,c,g,2,99)
		end
	end
	return returnval
end
function c249000697.spcon2(e,c,og)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCountFromEx(tp,tp,c)>0 and Duel.IsExistingMatchingCard(c249000697.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,c,e,tp)
end
function c249000697.spop2(e,tp,eg,ep,ev,re,r,rp,c,og)
	Duel.Hint(HINT_CARD,0,249000697)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local spg=Duel.SelectMatchingCard(tp,c249000697.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e:GetHandler(),e,tp)
	og:Merge(spg)
	Duel.SendtoGrave(e:GetHandler(),REASON_RULE)
	spg:GetFirst():SetMaterial(Group.FromCards(e:GetHandler()))
	Duel.Overlay(spg:GetFirst(),e:GetHandler())
end
function c249000697.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckOrExtraAsCost() end
	Duel.SendtoDeck(c,nil,2,REASON_COST)
end
function c249000697.filter1(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function c249000697.filter2(c)
	return c:IsSetCard(0x1E6)
end
function c249000697.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(c249000697.filter1,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(c249000697.filter2,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(19310321,1))
	local g1=Duel.SelectTarget(tp,c249000697.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(19310321,2))
	local g2=Duel.SelectTarget(tp,c249000697.filter2,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g2,1,0,0)
end
function c249000697.operation2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,tc,e)
	if g:GetCount()>0 then
		Duel.Overlay(tc,g)
	end
end