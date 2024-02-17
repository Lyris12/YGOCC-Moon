--Cyber-Varia Magic Link Evolution
function c249001283.initial_effect(c)
	c:SetUniqueOnField(1,0,249001283)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(2)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c249001283.condition)
	e2:SetTarget(c249001283.target)
	e2:SetOperation(c249001283.operation)
	c:RegisterEffect(e2)
	--link spell
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_LINK_SPELL_KOISHI)
	e3:SetRange(LOCATION_SZONE)
	e3:SetValue(LINK_MARKER_TOP)
	c:RegisterEffect(e3)
end
function c249001283.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1FD)
end
function c249001283.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c249001283.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c249001283.filter(c,e,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),Duel.ReadCard(c:GetOriginalCode(),CARDDATA_SETCODE),TYPE_MONSTER+TYPE_EFFECT+TYPE_LINK,0,0,2,RACE_CYBERSE,ATTRIBUTE_LIGHT)
end
function c249001283.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c249001283.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c249001283.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c249001283.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c249001283.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,tc:GetCode(),Duel.ReadCard(tc:GetOriginalCode(),CARDDATA_SETCODE),TYPE_MONSTER+TYPE_EFFECT+TYPE_LINK,0,0,2,RACE_CYBERSE,ATTRIBUTE_LIGHT) then
		--tc:AddMonsterAttribute(TYPE_EFFECT)
		tc:SetCardData(CARDDATA_TYPE,TYPE_MONSTER+TYPE_LINK+TYPE_EFFECT)
		tc:SetCardData(CARDDATA_RACE,RACE_CYBERSE)
		tc:SetCardData(CARDDATA_ATTRIBUTE,ATTRIBUTE_LIGHT)
		Duel.SpecialSummonStep(tc,0,tp,tp,true,true,POS_FACEUP_ATTACK)
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39507090,9))
		local linkval=0
		local linkmarkertable={
			LINK_MARKER_BOTTOM_LEFT,
			LINK_MARKER_BOTTOM,
			LINK_MARKER_BOTTOM_RIGHT,
			LINK_MARKER_LEFT,
			LINK_MARKER_RIGHT,
			LINK_MARKER_TOP_LEFT,
			LINK_MARKER_TOP,
			LINK_MARKER_TOP_RIGHT
		}
		local optiontable={
			aux.Stringid(39507090,0), --Bottom Left
			aux.Stringid(39507090,1), --Bottom
			aux.Stringid(39507090,2), --Bottom Right
			aux.Stringid(39507090,3), --Left
			aux.Stringid(39507090,4), --Right
			aux.Stringid(39507090,5), --Top Left
			aux.Stringid(39507090,6), --Top
			aux.Stringid(39507090,7) --Top Right
		}
		local i=0
		for i=0,1 do
			local op=Duel.SelectOption(tp,table.unpack(optiontable))
			linkval=linkval+linkmarkertable[op+1]
			table.remove(linkmarkertable,op+1)
			table.remove(optiontable,op+1)
		end
		tc:SetCardData(CARDDATA_LEVEL,2)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LINK_MARKER_KOISHI)
		e1:SetValue(linkval)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EVENT_LEAVE_FIELD_P)
		e2:SetOperation(c249001283.revertop)
		e2:SetReset(RESET_EVENT)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EVENT_TO_GRAVE)
		tc:RegisterEffect(e3)
		local e4=e2:Clone()
		e4:SetCode(EVENT_REMOVE)
		tc:RegisterEffect(e4)
		--redirect
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e5:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e5:SetValue(LOCATION_DECKSHF)
		tc:RegisterEffect(e5,true)
		--cannot facedown
		local e6=Effect.CreateEffect(c)
		e6:SetType(EFFECT_TYPE_SINGLE)
		e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e6:SetRange(LOCATION_MZONE)
		e6:SetCode(EFFECT_DIVINE_LIGHT)
		tc:RegisterEffect(e6,true)
		Duel.SpecialSummonComplete()
	end
end
function c249001283.revertop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:SetCardData(CARDDATA_LEVEL,Duel.ReadCard(c:GetOriginalCode(),CARDDATA_LEVEL))
	c:SetCardData(CARDDATA_TYPE,Duel.ReadCard(c:GetOriginalCode(),CARDDATA_TYPE))
	c:SetCardData(CARDDATA_RACE,Duel.ReadCard(c:GetOriginalCode(),CARDDATA_RACE))
	c:SetCardData(CARDDATA_ATTRIBUTE,Duel.ReadCard(c:GetOriginalCode(),CARDDATA_ATTRIBUTE))
	e:Reset()
end