--The Boundless Bridge Between Brilliances
--Il Ponte Sconfinato Tra gli Splendori
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[When this card is activated: You can reveal 1 Pandemonium Monster in your hand; Set it to your Spell/Trap Zone. That Set card can be activated this turn.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetFunctions(nil,aux.DummyCost,s.target,nil)
	c:RegisterEffect(e1)
	--[[If you Fusion, Synchro, Xyz, Link, Bigbang, or Time Leap Summon a monster(s) (except during the Damage Step): You can activate this effect;
	for the rest of this turn after this effect resolves, you cannot Special Summon monsters with the same monster card type (Fusion, Synchro, Xyz, Link, Bigbang, or Time Leap)
	as that Summoned monster(s), also Special Summon 1 monster that is banished or in your GY, and that was used as material for that Summon.]]
	aux.RegisterMergedDelayedEventGlitchy(c,id,EVENT_SPSUMMON_SUCCESS,s.spcfilter,id,LOCATION_FZONE)
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--[[If you control monsters with 3 or more different monster card types (Fusion, Synchro, Xyz, Link, Bigbang, Time Leap): You can draw 2 cards.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(4)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:HOPT()
	e3:SetFunctions(s.drawcon,nil,s.drawtg,s.drawop)
	c:RegisterEffect(e3)
end
--FE1
function s.thfilter(c)
	return ((c:IsSetCard(0x10c) and c:IsMonster()) or c:IsSetCard(0xfe)) and c:IsFaceup() and c:IsAbleToHand()
end
--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:IsCostChecked() and Duel.IsExists(false,aux.PandSSetFilter(aux.NOT(Card.IsPublic),tp),tp,LOCATION_HAND,0,1,nil) and Duel.IsPlayerCanDraw(tp,1)
	and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		e:SetOperation(s.activate)
		local g=Duel.Select(HINTMSG_CONFIRM,false,tp,aux.PandSSetFilter(aux.NOT(Card.IsPublic),tp),tp,LOCATION_HAND,0,1,1,nil)
		if #g>0 then
			Duel.ConfirmCards(1-tp,g)
			Duel.SetTargetCard(g)
		end
	else
		e:SetOperation(nil)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	aux.OperationRegistrationProcedure(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and Duel.PandSSet(tc,e,tp,REASON_EFFECT)>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end

--FE2
function s.spcfilter(c,_,tp)
	return c:IsSummonPlayer(tp) and c:GetMaterialCount()>0
		and (c:IsSummonType(SUMMON_TYPE_FUSION) or c:IsSummonType(SUMMON_TYPE_SYNCHRO) or c:IsSummonType(SUMMON_TYPE_XYZ) or c:IsSummonType(SUMMON_TYPE_LINK) or c:IsSummonType(SUMMON_TYPE_BIGBANG)
		or c:IsSummonType(SUMMON_TYPE_TIMELEAP))
end
function s.spfilter(c,e,tp,eg)
	return c:IsFaceupEx() and c:IsMonster() and c:IsReason(REASON_MATERIAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and eg:IsContains(c:GetReasonCard())
end
--E2
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return eg and #eg>0 and Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_GB,LOCATION_REMOVED,1,nil,e,tp,eg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GB)
	Duel.SetAdditionalOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)>0 then
		local sumtype=0
		local summon_types={TYPE_FUSION,TYPE_SYNCHRO,TYPE_XYZ,TYPE_LINK,TYPE_BIGBANG,TYPE_TIMELEAP}
		local bool_table={}
		local ct=0
		for _,sumtyp in ipairs(summon_types) do
			local bool=eg:IsExists(Card.IsType,1,nil,sumtyp) and Duel.IsExists(false,aux.Necro(s.spfilter),tp,LOCATION_GB,LOCATION_REMOVED,1,nil,e,tp,eg:Filter(Card.IsType,nil,sumtyp))
			if bool then
				ct=ct+1
			end
			table.insert(bool_table,bool)
		end
		if ct>1 then
			local opt=aux.Option(tp,id,5,table.unpack(bool_table))
			sumtype=summon_types[opt+1]
		end
		local sumg = sumtype>0 and eg:Filter(Card.IsType,nil,sumtype) or eg
		local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_GB,LOCATION_REMOVED,1,1,nil,e,tp,sumg)
		if #g>0 then
			local typ=g:GetFirst():GetReasonCard():GetType()&(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK|TYPE_BIGBANG|TYPE_TIMELEAP)
			if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e1:SetTargetRange(1,0)
				e1:SetTarget(aux.TargetBoolFunction(Card.IsType,typ))
				e1:SetReset(RESET_PHASE|PHASE_END)
				Duel.RegisterEffect(e1,tp)
				if not Duel.PlayerHasFlagEffect(tp,id) then
					Duel.RegisterHint(tp,id,PHASE_END,1,id,3)
				end
			end
		end
	end
end

--E3
function s.classfunction(c)
	return c:GetType()&(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK|TYPE_BIGBANG|TYPE_TIMELEAP)
end
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil):GetClassCount(s.classfunction)>=3
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end