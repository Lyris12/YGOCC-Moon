--[[
Dynastygian Engineer - "Kobold"
Geniere Dinastigiano - "Coboldo"
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[Each time a "Dynastygian" monster(s) is Special Summoned to your field, immediately gain 400 LP for each of those monsters.]]
	aux.RegisterMaxxCEffect(c,id,nil,LOCATION_MZONE,EVENT_SPSUMMON_SUCCESS,s.reccon,s.recopOUT,s.recopIN,s.flaglabel,false,false,nil,aux.AddThisCardInMZoneAlreadyCheck(c))
	--[[During your Main Phase, if you control a "Dynastygian" monster: You can Special Summon this card from your hand, and if you do,
	add 1 "Dynastygian" Spell/Trap from your Deck or GY to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCategory(CATEGORIES_SEARCH|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:HOPT()
	e2:SetFunctions(
		aux.LocationGroupCond(aux.FaceupFilter(Card.IsSetCard,ARCHE_DYNASTYGIAN),LOCATION_MZONE,0,1),
		nil,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e2)
	--[[During your Main Phase: You can make the Levels of all face-up "Dynastygian" monsters you currently control become 10 (until the end of the turn),
	and if you do, you cannot Special Summon Xyz Monsters from your Extra Deck for the rest of this turn, except DARK "Number" Xyz Monsters.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetCustomCategory(CATEGORY_LVCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetFunctions(
		nil,
		nil,
		s.lvtg,
		s.lvop
	)
	c:RegisterEffect(e3)
end
--E1
function s.cfilter(c,p)
	return c:IsFaceup() and c:IsSetCard(ARCHE_DYNASTYGIAN) and c:IsControler(p)
end
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(aux.AlreadyInRangeFilter(e,s.cfilter),1,nil,tp)
end
function s.flaglabel(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(aux.AlreadyInRangeFilter(e,s.cfilter),nil,tp)
end
function s.recopOUT(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local ct=eg:FilterCount(aux.AlreadyInRangeFilter(e,s.cfilter),nil,tp)
	Duel.Recover(tp,ct*400,REASON_EFFECT)
end
function s.recopIN(e,tp,eg,ep,ev,re,r,rp,n)
	Duel.Hint(HINT_CARD,tp,id)
	local labels={Duel.GetFlagEffectLabel(tp,id)}
	local ct=0
	for i=1,#labels do
		ct=ct+labels[i]
	end
	Duel.Recover(tp,ct*400,REASON_EFFECT)
end

--E2
function s.thfilter(c)
	return c:IsST() and c:IsSetCard(ARCHE_DYNASTYGIAN) and c:IsAbleToHand()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.Search(g)
		end
	end
end

--E4
function s.lvfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(ARCHE_DYNASTYGIAN) and c:IsCanChangeLevel(10,e,tp,REASON_EFFECT)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.lvfilter,tp,LOCATION_MZONE,0,nil,e,tp)
	if chk==0 then
		return #g>0
	end
	Duel.SetCustomOperationInfo(0,CATEGORY_LVCHANGE,g,#g,0,0,{10})
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.lvfilter,tp,LOCATION_MZONE,0,nil,e,tp)
	if #g==0 then return end
	local c=e:GetHandler()
	local check=false
	for tc in aux.Next(g) do
		local e,diff=tc:ChangeLevel(10,true,{c,true})
		if not check and not tc:IsImmuneToEffect(e) and diff~=0 and tc:IsLevel(10) then
			check=true
		end
	end
	if check then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(id,2)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and c:IsType(TYPE_XYZ) and not (c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK))
end