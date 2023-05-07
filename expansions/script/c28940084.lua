--Chanteil, Monkastery Initiate
local ref,id=GetID()
Duel.LoadScript("Monkastery.lua")
function ref.initial_effect(c)
	aux.AddLinkProcedure(c,function(c) return Monkastery.Is(c) and c:IsSummonType(SUMMON_TYPE_NORMAL) end,1)
	c:EnableReviveLimit()
	--Set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end)
	e1:SetTarget(ref.settg)
	e1:SetOperation(ref.setop)
	c:RegisterEffect(e1)
	--Revive
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE+CATEGORY_RELEASE+CATEGORY_ATKCHANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetType(EFFECT_TYPE_QUICK_O+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp,eg,ep,ev,re) return re:IsActiveType(TYPE_TRAP) end)
	e2:SetTarget(ref.sstg)
	e2:SetOperation(ref.ssop)
	c:RegisterEffect(e2)
end

--Set
function ref.setfilter(c) return c:IsSetCard(Monkastery.Code+0x1000) and c:IsSSetable() end
function ref.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(ref.setfilter,tp,LOCATION_DECK,0,1,nil)
	end
end
function ref.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(ref.setfilter,tp,LOCATION_DECK,0,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,ref.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then Duel.SSet(tp,g) end
	end
end

--Revive
function ref.filter(c,ec,e,tp)
	if not (Monkastery.Is(c) and c:IsType(TYPE_MONSTER)) then return false end
	local g=Group.FromCards(c,ec)
	return g:IsExists(ref.ofilter,1,nil,g,e,tp)
end
function ref.sscfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemove())
		or (c:IsLocation(LOCATION_MZONE) and c:IsReleasable())
end
function ref.ofilter(c,g,e,tp)
	return (c:IsCanBeSpecialSummoned(e,0,tp,false,false) or c:IsLocation(LOCATION_MZONE)) and g:IsExists(ref.sscfilter,1,c)
end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and ref.filter(chkc,c,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(ref.filter,tp,LOCATION_GRAVE,0,1,nil,c,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectTarget(tp,ref.filter,tp,LOCATION_GRAVE,0,1,1,nil,c,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,0,0)
end
function ref.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fg=(Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)+c):Filter(Card.IsRelateToEffect,nil,e)
	if fg:GetCount()~=2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local sg=fg:FilterSelect(tp,ref.ofilter,1,1,nil,fg,e,tp)
	fg:Sub(sg)
	local sc=sg:GetFirst()
	if sc:IsLocation(LOCATION_MZONE) then Duel.Remove(fg,POS_FACEUP,REASON_EFFECT) end
	if sc:IsLocation(LOCATION_GRAVE) and Duel.Release(fg,REASON_EFFECT)~=0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
	if sc:IsLocation(LOCATION_MZONE) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(3000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		sc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetDescription(aux.Stringid(id,2))
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetValue(ref.immval)
		sc:RegisterEffect(e2)
	end
end
function ref.immval(e,re)
	if re:GetHandler()==e:GetHandler() or not re:IsActivated() then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g or not g:IsContains(e:GetHandler())
end
