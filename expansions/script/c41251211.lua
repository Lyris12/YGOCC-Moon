--Daylilly Path
--created by Alastar Rainford, originally coded by Lyris
--Rescripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.EnableChangeCode(c,CARD_BLACK_GARDEN,LOCATION_SZONE)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	c:RegisterEffect(e1)
	--token
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORIES_TOKEN)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
function s.filter(c,tp)
	local ft1,ft2=Duel.GetMZoneCount(tp,c),Duel.GetMZoneCount(tp,c,1-tp)
	local ft=ft1+ft2
	local lv=c:GetOriginalRatingAuto()
	if c:IsFacedown() or c:IsType(TYPE_EFFECT) or not c:IsRace(RACE_PLANT) or lv==0 or ft==0 or lv>ft or (ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then return false end
	Debug.Message("-----")
	Debug.Message(c:GetCode())
	Debug.Message(lv.." "..ft)
	if lv<=ft1 then
		return Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_DAYLILLY,ARCHE_DAYLILLY,TYPES_TOKEN_MONSTER,400,400,1,RACE_PLANT,ATTRIBUTE_DARK)
	elseif lv<=ft2 then
		return Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_DAYLILLY,ARCHE_DAYLILLY,TYPES_TOKEN_MONSTER,400,400,1,RACE_PLANT,ATTRIBUTE_DARK,POS_FACEUP,1-tp)
	elseif lv<=ft then
		for p=0,1 do
			if not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_DAYLILLY,ARCHE_DAYLILLY,TYPES_TOKEN_MONSTER,400,400,1,RACE_PLANT,ATTRIBUTE_DARK,POS_FACEUP,p) then
				return false
			end
		end
		return true
	end
	return false
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	local g=Duel.Group(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,g:GetControlers(),LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	local tc=g:GetFirst()
	if not tc or Duel.Destroy(tc,REASON_EFFECT)==0 then return end
	local ct=tc:GetOriginalRatingAuto()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)+Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if ct>ft or (ct>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then return end
	local c=e:GetHandler()
	for i=1,ct do
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_DAYLILLY,ARCHE_DAYLILLY,TYPES_TOKEN_MONSTER,400,400,1,RACE_PLANT,ATTRIBUTE_DARK)
		local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_DAYLILLY,ARCHE_DAYLILLY,TYPES_TOKEN_MONSTER,400,400,1,RACE_PLANT,ATTRIBUTE_DARK,POS_FACEUP,1-tp)
		local op=aux.Option(tp,id,2,b1,b2)
		local p = (op==0) and tp or 1-tp
		if i==1 and op then Duel.BreakEffect() end
		local token=Duel.CreateToken(tp,TOKEN_DAYLILLY)
		if Duel.SpecialSummonStep(token,0,tp,p,false,false,POS_FACEUP) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			token:RegisterEffect(e1,true)
		end
	end
	Duel.SpecialSummonComplete()
end