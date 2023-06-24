--Rivalry of Star Conductors
--Rivalità delle Conduttrici di Stelle
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--[[Reveal 1 monster in your Extra Deck, then apply 1 of the following effects, depending on its monster card type.
	● Fusion or Synchro: Send 1 monster with the same Type as the revealed monster from your Deck to your GY, and if you do,
	Special Summon 1 Rival Token (Tuner/ATK 0/DEF 0) with the same Type, Attribute and Level as the sent monster, but you cannot Special Summon monsters for the rest of this turn,
	except monsters with the same Type as the revealed monster.
	● Bigbang: Destroy 1 monster in your Deck with the same Vibe as the revealed monster, but for the rest of this turn, any damage your opponent takes is halved.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_TOKEN|CATEGORY_TOGRAVE|CATEGORY_DECKDES|CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
--FILTERS E1
function s.filter(c,e,tp)
	if not c:IsMonster() then return false end
	local chk1,chk2=false,false
	if c:IsType(TYPE_FUSION|TYPE_SYNCHRO) then
		if Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.tgfilter,tp,LOCATION_DECK,0,1,c,tp,c:GetRace()) then
			return true
		end
	end
	if c:IsType(TYPE_BIGBANG) then
		if Duel.IsExists(false,s.desfilter,tp,LOCATION_DECK,0,1,c,e,c:GetVibe()) then
			return true
		end
	end
	return false
end
function s.tgfilter(c,tp,rc,attr,lv,nochk)
	return c:IsMonster() and c:IsRace(rc) and c:HasLevel() and c:IsAbleToGrave()
		and (nochk or Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_RIVAL,0,TYPES_TOKEN_MONSTER|TYPE_TUNER,0,0,c:GetLevel(),c:GetRace(),c:GetAttribute()))
end
function s.desfilter(c,e,vibe)
	return c:IsMonster() and c:HasVibe() and c:GetVibe()==vibe and c:IsDestructable(e)
end
--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_CONFIRM,false,tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.ConfirmCards(1-tp,g)
		local tc=g:GetFirst()
		local b1 = (tc:IsType(TYPE_FUSION|TYPE_SYNCHRO) and Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.tgfilter,tp,LOCATION_DECK,0,1,tc,tp,tc:GetRace()))
		local b2 = (tc:IsType(TYPE_BIGBANG) and Duel.IsExists(false,s.desfilter,tp,LOCATION_DECK,0,1,tc,e,tc:GetVibe()))
		local opt=aux.Option(tp,id,1,b1,b2)
		local c=e:GetHandler()
		if opt==0 then
			local race=tc:GetRace()
			local tg=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,tp,race,nil,nil,true)
			if #tg>0 then
				local gc=tg:GetFirst()
				local rc,attr,lv = gc:GetRace(),gc:GetAttribute(),gc:GetLevel()
				Duel.BreakEffect()
				if Duel.SendtoGrave(gc,REASON_EFFECT)>0 and aux.PLChk(gc,nil,LOCATION_GRAVE) and Duel.GetMZoneCount(tp)>0
					and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_RIVAL,0,TYPES_TOKEN_MONSTER|TYPE_TUNER,0,0,lv,rc,attr) then
					local token=Duel.CreateToken(tp,TOKEN_RIVAL)
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_CHANGE_RACE)
					e1:SetValue(rc)
					e1:SetReset(RESET_EVENT|RESETS_STANDARD_TOFIELD)
					token:RegisterEffect(e1)
					local e2=e1:Clone()
					e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
					e2:SetValue(attr)
					token:RegisterEffect(e2)
					local e3=e1:Clone()
					e3:SetCode(EFFECT_CHANGE_LEVEL)
					e3:SetValue(lv)
					token:RegisterEffect(e3)
					Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
				end
			end
			local e1=Effect.CreateEffect(c)
			e1:Desc(3)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
			e1:SetTargetRange(1,0)
			e1:SetLabel(race)
			e1:SetTarget(s.splimit)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
		
		elseif opt==1 then
			local tg=Duel.Select(HINTMSG_DESTROY,false,tp,s.desfilter,tp,LOCATION_DECK,0,1,1,nil,e,tc:GetVibe())
			if #tg>0 then
				Duel.Destroy(tg,REASON_EFFECT)
			end
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CHANGE_DAMAGE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(0,1)
			e1:SetValue(s.damval)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
			Duel.RegisterHint(1-tp,id,PHASE_END,1,id,4)
		end
	end
end
function s.splimit(e,c)
	return not c:IsRace(e:GetLabel())
end
function s.damval(e,re,val,r,rp,rc)
	return math.floor(val/2)
end