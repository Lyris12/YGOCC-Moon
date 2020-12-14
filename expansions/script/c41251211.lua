--created by Alastar Rainford, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_ONFIELD)
	e2:SetValue(CARD_BLACK_GARDEN)
	c:RegisterEffect(e2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	local ft=Duel.GetMZoneCount(tp,c)+Duel.GetMZoneCount(tp,c,1-tp)
	local lv=c:GetLink()>0 and c:GetLink() or c:GetOriginalRank()>0 and c:GetOriginalRank() or c:GetOriginalLevel()
	if c:IsFacedown() or c:IsType(TYPE_EFFECT) or not c:IsRace(RACE_PLANT) or lv==0 or lv>ft
		or (ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then return false end
	for p=0,1 do
		if Duel.GetLocationCount(p,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id-11,0xf95,0x4011,400,400,1,RACE_PLANT,ATTRIBUTE_DARK,POS_FACEUP,p) then return true end
	end
	return false
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,PLAYER_ALL,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,0,PLAYER_ALL,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	local tc=g:GetFirst()
	if not tc or Duel.Destroy(tc,REASON_EFFECT)==0 then return end
	local ct=tc:GetLink()>0 and tc:GetLink() or tc:GetOriginalRank()>0 and tc:GetOriginalRank() or tc:GetOriginalLevel()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)+Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id-11,0xf95,0x4011,400,400,1,RACE_PLANT,ATTRIBUTE_DARK)
		or ct>ft or (ct>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then return end
	for i=1,ct do
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id-11,0xf95,0x4011,400,400,1,RACE_PLANT,ATTRIBUTE_DARK,POS_FACEUP,tp)
		local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id-11,0xf95,0x4011,400,400,1,RACE_PLANT,ATTRIBUTE_DARK,POS_FACEUP,1-tp)
		local op=0
		if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,0))
		elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(id,1))
		else op=Duel.SelectOption(tp,aux.Stringid(id,0))+1 end
		local p=tp
		if op>0 then p=1-tp end
		if i==1 then Duel.BreakEffect() end
		local token=Duel.CreateToken(tp,id-11)
		Duel.SpecialSummonStep(token,0,tp,p,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
	end
	Duel.SpecialSummonComplete()
end
