--[[
Choir of Verdanse
Coro di Verdanse
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	--You can only control 1 "Choir of Verdanse".
	c:SetUniqueOnField(1,0,id)
	--[[When this card is activated: You can take 1 "Verdanse" Ritual Monster from your Deck or GY, send up to 2 monsters from your Deck to the GY,
	whose total Levels equal the Level of that monster, and if you do, Special Summon that monster. (This is treated as a Ritual Summon.)
	If your opponent controls a monster that began the Duel in the Extra Deck, you can send 1 Xyz Monster from your Extra Deck to the GY to Special Summon that monster, instead.]]
	local e1=c:Activation(true,nil,nil,nil,s.target,s.activate,true)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TOGRAVE|CATEGORY_DECKDES|CATEGORY_GRAVE_SPSUMMON)
	e1:SetCustomCategory(CATEGORY_SPSUMMON_RITUAL_MONSTER)
	c:RegisterEffect(e1)
	--[[All "Verdanse" monsters you control cannot be destroyed by battle, also DARK Xyz Monsters you control cannot be targeted by card effects.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,ARCHE_VERDANSE))
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTarget(function(e,c) return c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK) end)
	c:RegisterEffect(e3)
	--[[Each time you Ritual Summon a "Verdanse" Ritual Monster(s) while you control a DARK Xyz Monster,
	you can immediately attach the top card of both player's Decks to 1 DARK Xyz Monster you control.]]
	local SZChk=aux.AddThisCardInSZoneAlreadyCheck(c)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetLabelObject(SZChk)
	e4:SetCondition(s.drcon1)
	e4:SetOperation(s.drop1)
	c:RegisterEffect(e4)
	--sp_summon effect
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_FIELD)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetRange(LOCATION_SZONE)
	e5:SetLabelObject(SZChk)
	e5:SetCondition(s.regcon)
	e5:SetOperation(s.regop)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_FIELD)
	e6:SetCode(EVENT_CHAIN_SOLVED)
	e6:SetRange(LOCATION_SZONE)
	e6:SetLabelObject(SZChk)
	e6:SetCondition(s.drcon2)
	e6:SetOperation(s.drop2)
	c:RegisterEffect(e6)
end
--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
	Duel.SetPossibleCustomOperationInfo(0,CATEGORY_SPSUMMON_RITUAL_MONSTER,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.matfilter(c,rc)
	return c:IsMonster() and c:GetRitualLevel(rc)>0 and c:IsAbleToGrave() and c:IsCanBeRitualMaterial(rc)
end
function s.exmatfilter(c,rc)
	return c:IsMonster(TYPE_XYZ) and c:IsAbleToGrave() and c:IsCanBeRitualMaterial(rc)
end
function s.ritfilter(c,e,tp,exmatcheck)
	if not c:IsMonster(TYPE_RITUAL) or not c:IsSetCard(ARCHE_VERDANSE) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mats=Duel.Group(s.matfilter,tp,LOCATION_DECK,0,c,c)
	local exmats=Duel.Group(s.exmatfilter,tp,LOCATION_EXTRA,0,c,c)
	return (exmatcheck and #exmats>0) or mats:CheckSubGroup(s.gcheck,1,2,c,c:GetLevel())
end
function s.gcheck(g,c,lv)
	return g:CheckWithSumEqual(Card.GetRitualLevel,lv,#g,#g,c)
end
function s.matselection(g,c,lv)
	if not g:IsExists(Card.IsType,1,nil,TYPE_XYZ) then
		return g:CheckWithSumEqual(Card.GetRitualLevel,lv,#g,#g,c)
	else
		return #g==1
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local exmatcheck=Duel.IsExists(false,Card.IsOriginalType,tp,0,LOCATION_MZONE,1,nil,TYPE_EXTRA)
	if Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,aux.Necro(s.ritfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp,exmatcheck) and Duel.SelectYesNo(tp,STRING_ASK_SPSUMMON) then
		local rc=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.ritfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp,exmatcheck):GetFirst()
		if rc then
			local mats=Duel.Group(s.matfilter,tp,LOCATION_DECK,0,rc,rc)
			if exmatcheck then
				local exmats=Duel.Group(s.exmatfilter,tp,LOCATION_EXTRA,0,rc,rc)
				mats:Merge(exmats)
			end
			Duel.HintMessage(tp,HINTMSG_TOGRAVE)
			local mg=mats:SelectSubGroup(tp,s.matselection,false,1,2,rc,rc:GetLevel())
			if #mg>0 then
				rc:SetMaterial(mg)
				if Duel.SendtoGrave(mg,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)>0 and mg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==#mg then
					if Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)>0 then
						rc:CompleteProcedure()
					end
				end
			end	
		end
	end
end

--E4
function s.cfilter(c,sp)
	return c:IsSummonPlayer(sp) and c:IsFaceup() and c:IsMonster(TYPE_RITUAL) and c:IsSetCard(ARCHE_VERDANSE) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.drcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(aux.AlreadyInRangeFilter(e,s.cfilter),1,nil,tp) and Duel.IsExists(false,s.xyzfilter,tp,LOCATION_MZONE,0,1,eg)
		and not Duel.IsChainSolving()
end
function s.drop1(e,tp,eg,ep,ev,re,r,rp)
	local tc1,tc2=Duel.GetDecktopGroup(tp,1):GetFirst(),Duel.GetDecktopGroup(1-tp,1):GetFirst()
	if not tc1 or not tc2 then return end
	local matg=Group.FromCards(tc1,tc2):Filter(Card.IsCanOverlay,nil,tp)
	if #matg~=2 then return end
	local g=Duel.Group(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
	if #g<=0 then return end
	local c=e:GetHandler()
	Duel.HintSelection(Group.FromCards(c))
	if Duel.SelectYesNo(tp,STRING_ASK_ATTACH) then
		Duel.HintMessage(tp,HINTMSG_FACEUP)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.Hint(HINT_CARD,tp,id)
			Duel.HintSelection(sg)
			Duel.DisableShuffleCheck()
			Duel.Attach(matg,sg:GetFirst())
		end
	end
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(aux.AlreadyInRangeFilter(e,s.cfilter),1,nil,tp) and Duel.IsExists(false,s.xyzfilter,tp,LOCATION_MZONE,0,1,eg)
		and Duel.IsChainSolving()
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
end
function s.drcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>0
end
function s.drop2(e,tp,eg,ep,ev,re,r,rp)
	local n=Duel.GetFlagEffect(tp,id)
	Duel.ResetFlagEffect(tp,id)
	local c=e:GetHandler()
	for i=1,n do
		local tc1,tc2=Duel.GetDecktopGroup(tp,1):GetFirst(),Duel.GetDecktopGroup(1-tp,1):GetFirst()
		if not tc1 or not tc2 then return end
		local matg=Group.FromCards(tc1,tc2):Filter(Card.IsCanOverlay,nil,tp)
		if #matg~=2 then return end
		local g=Duel.Group(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
		if #g<=0 then return end
		Duel.HintSelection(Group.FromCards(c))
		if Duel.SelectYesNo(tp,STRING_ASK_ATTACH) then
			Duel.HintMessage(tp,HINTMSG_FACEUP)
			local sg=g:Select(tp,1,1,nil)
			if #sg>0 then
				Duel.Hint(HINT_CARD,tp,id)
				Duel.HintSelection(sg)
				Duel.DisableShuffleCheck()
				Duel.Attach(matg,sg:GetFirst())
			end
		end
	end
end