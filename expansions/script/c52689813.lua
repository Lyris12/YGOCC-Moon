--Goldriver
--Driveolo Dorato
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--[[When this card is activated: You can excavate cards from the top of your Deck, equal to the Energy of your Engaged monster (max. 12),
	and if you do, Special Summon 1 excavated Drive Monster, and if you do that, reduce the Energy of your Engaged monster to 0. Also, shuffle the rest into the Deck.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--[[You can target 1 other face-up card you control; destroy it, and if you do, Set 1 "Hyperdrive" Spell/Trap from your GY.
	If you destroyed a Drive Monster in a Monster Zone (even if it was face-down), you can Set directly from your Deck instead.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:HOPT()
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.spfilter(c,e,tp)
	return c:IsMonster(TYPE_DRIVE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.PlayerHasFlagEffect(tp,id) then return end
	local en=Duel.GetEngagedCard(tp)
	if not en then return end
	local n=math.min(en:GetEnergy(),12)
	if n>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=n and Duel.GetMZoneCount(tp)>0 and Duel.IsPlayerCanSpecialSummon(tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.ConfirmDecktop(tp,n)
		local g=Duel.GetDecktopGroup(tp,n):Filter(s.spfilter,nil,e,tp)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,1,1,nil)
			Duel.DisableShuffleCheck()
			if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
				en=Duel.GetEngagedCard(tp)
				if en and en:IsCanChangeEnergy(0,tp,REASON_EFFECT) then
					en:ChangeEnergy(0,tp,REASON_EFFECT,true,e:GetHandler())
				end
			end
		end
		Duel.ShuffleDeck(tp)
	end
end

function s.desfilter(c,tp)
	if c:IsFacedown() then return false end
	local loc=LOCATION_GRAVE
	if c:IsMonster(TYPE_DRIVE) and c:IsLocation(LOCATION_MZONE) then
		loc=loc|LOCATION_DECK
	end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	return Duel.IsExistingMatchingCard(s.filter,tp,loc,0,1,nil,ft,c)
end
function s.filter(c,ft,dc)
	if not c:IsSetCard(ARCHE_HYPERDRIVE) or not c:IsST() then return false end
	if c:IsType(TYPE_FIELD) and c:IsSSetable() then return true end
	if ft and ft==0 and dc:IsInBackrow() then
		return c:IsSSetable(true)
	else
		return c:IsSSetable()
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.desfilter(chkc,tp) and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,c,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		local check = tc:IsMonster(TYPE_DRIVE) and tc:IsLocation(LOCATION_MZONE)
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			local loc=LOCATION_GRAVE
			if check then
				loc=loc|LOCATION_DECK
			end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local g=Duel.SelectMatchingCard(tp,s.filter,tp,loc,0,1,1,nil)
			if #g>0 then
				Duel.SSet(tp,g)
			end
		end
	end
end