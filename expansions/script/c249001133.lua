--Infinity the Grand Naviigator
xpcall(function() require("expansions/script/c39507090") end,function() require("script/c39507090") end)
function c249001133.initial_effect(c)
	c:SetUniqueOnField(1,0,249001131)
	--link summon
	aux.AddLinkProcedure(c,nil,2,99,c249001133.lcheck)
	c:EnableReviveLimit()
	--copy
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c249001133.arcon)
	e1:SetTarget(c249001133.artg)
	e1:SetOperation(c249001133.arop)
	c:RegisterEffect(e1)
	--Destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetTarget(c249001133.desreptg)
	c:RegisterEffect(e2)
end
function c249001133.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x22B)
end
function c249001133.arcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c249001133.arfilter(c)
	return c:IsType(TYPE_LINK) and c:GetLink() <=4
end
function c249001133.artg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001133.arfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil) end
end
function c249001133.arop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.SelectMatchingCard(tp,c249001133.arfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()==0 then return end
	Duel.ConfirmCards(1-tp,g)
	c:CopyEffect(g:GetFirst():GetOriginalCode(),RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TOGRAVE-RESET_TEMP_REMOVE-RESET_REMOVE-RESET_LEAVE)
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
	for i=0,3 do
		local op=Duel.SelectOption(tp,table.unpack(optiontable))
		linkval=linkval+linkmarkertable[op+1]
		table.remove(linkmarkertable,op+1)
		table.remove(optiontable,op+1)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LINK_MARKER_KOISHI)
	e1:SetValue(linkval)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TOGRAVE-RESET_TEMP_REMOVE-RESET_REMOVE-RESET_LEAVE)
	c:RegisterEffect(e1,true)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ADD_CODE)
	e2:SetValue(g:GetFirst():GetOriginalCode())
	e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TOGRAVE-RESET_TEMP_REMOVE-RESET_REMOVE-RESET_LEAVE)	
	c:RegisterEffect(e2)
end
function c249001133.repfilter(c)
	return c:IsSetCard(0x22B) and c:IsAbleToRemoveAsCost()
end
function c249001133.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT)
		and Duel.IsExistingMatchingCard(c249001133.repfilter,tp,LOCATION_GRAVE,0,1,nil) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c249001133.repfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		return true
	else return false end
end